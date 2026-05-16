// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_octoai/otel_octoai.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(serviceName: 'otel_octoai-test');
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('text.chatCompletions records model + ttft + tokens', () async {
    await tracedOctoAi<String>(
      operation: 'text.chatCompletions',
      invoke: () async => const OctoAiCallResult(
        value: 'ok',
        result: OctoAiResult(
          surface: 'text_gen',
          modelName: 'meta-llama-3.1-70b-instruct',
          modelFamily: 'llama',
          quantization: 'fp16',
          gpu: 'h100',
          streamed: true,
          promptTokens: 540,
          completionTokens: 220,
          totalTokens: 760,
          tokensPerSecond: 92.5,
          timeToFirstTokenMs: 280,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('octoai text.chatCompletions')!);
    expect(a['octoai.model.family'], 'llama');
    expect(a['octoai.gpu'], 'h100');
    expect(a['octoai.usage.total_tokens'], 760);
  });

  test('image.generate records steps + dimensions', () async {
    await tracedOctoAi<String>(
      operation: 'image.generate',
      invoke: () async => const OctoAiCallResult(
        value: 'ok',
        result: OctoAiResult(
          surface: 'image_gen',
          modelFamily: 'flux',
          imageSteps: 30,
          imageCount: 4,
          imageWidth: 1024,
          imageHeight: 1024,
          creditsUsed: 12,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('octoai image.generate')!);
    expect(a['octoai.image.steps'], 30);
    expect(a['octoai.image.count'], 4);
  });

  test('error sets span error', () async {
    await tracedOctoAi<String>(
      operation: 'text.chatCompletions',
      invoke: () async => const OctoAiCallResult(
        value: 'ok',
        result: OctoAiResult(errorCode: 'rate_limited', statusCode: 429),
      ),
    );
    expect(
      spans.findSpanByName('octoai text.chatCompletions')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutOctoAiInstrumentationAsync(() async {
      await tracedOctoAi<String>(
        operation: 'endpoints.list',
        invoke: () async => const OctoAiCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('octoai '), isEmpty);
  });
}
