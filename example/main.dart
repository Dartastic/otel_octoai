// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_octoai/otel_octoai.dart';

/// Traces OctoAI calls with OpenTelemetry.
///
/// `otel_octoai` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each OctoAI call in
/// [tracedOctoAi]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'octoai-example');

  // Wraps an OctoAI call in a CLIENT span.
  final octoAiId = await tracedOctoAi<String>(
    operation: 'assets.create',
    invoke: () async {
      // Make the OctoAI call here, then report what it returned.
      const id = 'octoai_8f3a2c';
      return const OctoAiCallResult(
          value: id,
          result: OctoAiResult(
              surface: 'text_gen',
              endpointName: 'my-llama-3.1-70b',
              modelName: 'standard',
              modelFamily: 'llama',
              quantization: 'fp16',
              gpu: 'a100-80gb',
              streamed: true,
              promptTokens: 128,
              completionTokens: 128,
              totalTokens: 128,
              tokensPerSecond: 0.5,
              timeToFirstTokenMs: 128,
              imageSteps: 1,
              imageCount: 3,
              imageWidth: 1,
              imageHeight: 1,
              audioSeconds: 1,
              creditsUsed: 1,
              errorCode: 'example',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedOctoAi assets.create returned $octoAiId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutOctoAiInstrumentationAsync.
  await runWithoutOctoAiInstrumentationAsync(
    () => tracedOctoAi<String>(
      operation: 'assets.create',
      invoke: () async {
        const id = 'octoai_8f3a2c';
        return const OctoAiCallResult(
            value: id,
            result: OctoAiResult(
                surface: 'text_gen',
                endpointName: 'my-llama-3.1-70b',
                modelName: 'standard',
                modelFamily: 'llama',
                quantization: 'fp16',
                gpu: 'a100-80gb',
                streamed: true,
                promptTokens: 128,
                completionTokens: 128,
                totalTokens: 128,
                tokensPerSecond: 0.5,
                timeToFirstTokenMs: 128,
                imageSteps: 1,
                imageCount: 3,
                imageWidth: 1,
                imageHeight: 1,
                audioSeconds: 1,
                creditsUsed: 1,
                errorCode: 'example',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
