// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_octoai_suppression.dart';

const _tracerName = 'dartastic_otel_libs_octoai';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class OctoAiResult {
  const OctoAiResult({
    this.surface,
    this.endpointName,
    this.modelName,
    this.modelFamily,
    this.quantization,
    this.gpu,
    this.streamed,
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
    this.tokensPerSecond,
    this.timeToFirstTokenMs,
    this.imageSteps,
    this.imageCount,
    this.imageWidth,
    this.imageHeight,
    this.audioSeconds,
    this.creditsUsed,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// `text_gen`, `image_gen`, `audio`, `assets`, `tune`, `endpoints`,
  /// `media_gen_audio`, `media_gen_video`.
  final String? surface;

  /// Custom inference endpoint name (`my-llama-3.1-70b`).
  final String? endpointName;

  final String? modelName;

  /// `llama`, `mixtral`, `mistral`, `qwen`, `deepseek`, `gemma`,
  /// `sdxl`, `stable_diffusion`, `flux`, `whisper`, `bark`.
  final String? modelFamily;

  /// `fp16`, `fp8`, `int8`, `awq`, `gptq`.
  final String? quantization;

  /// GPU type backing the inference (`a100-80gb`, `h100`, `l40s`, ...).
  final String? gpu;

  final bool? streamed;

  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;

  final double? tokensPerSecond;
  final int? timeToFirstTokenMs;

  // ── Image gen ──────────────────────────────────────────────────
  final int? imageSteps;
  final int? imageCount;
  final int? imageWidth;
  final int? imageHeight;

  // ── Audio (Whisper, TTS) ──────────────────────────────────────
  final int? audioSeconds;

  /// OctoAI credits charged.
  final int? creditsUsed;

  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

class OctoAiCallResult<T> {
  const OctoAiCallResult({required this.value, this.result});
  final T value;
  final OctoAiResult? result;
}

/// Wraps an OctoAI call in a CLIENT span. [operation] is one of
/// `text.chatCompletions`, `text.completions`, `text.embeddings`,
/// `image.generate`, `image.adetailer`, `image.controlnet`,
/// `image.upscale`, `image.background.remove`, `image.background.replace`,
/// `image.faceSwap`, `audio.transcribe`, `audio.translate`,
/// `audio.generate`, `assets.create`, `assets.list`, `assets.delete`,
/// `tune.create`, `tune.list`, `tune.delete`,
/// `endpoints.create`, `endpoints.list`, `endpoints.delete`,
/// `endpoints.update`, `endpoints.scale`.
Future<T> tracedOctoAi<T>({
  required String operation,
  required Future<OctoAiCallResult<T>> Function() invoke,
}) async {
  if (octoAiInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'octoai',
    'rpc.method': operation,
    'octoai.operation': operation,
  };

  final span = _tracer().startSpan(
    'octoai $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.surface != null) {
        extras.add(OTel.attributeString('octoai.surface', res.surface!));
      }
      if (res.endpointName != null) {
        extras.add(OTel.attributeString(
          'octoai.endpoint.name',
          res.endpointName!,
        ));
      }
      if (res.modelName != null) {
        extras.add(OTel.attributeString('octoai.model.name', res.modelName!));
      }
      if (res.modelFamily != null) {
        extras.add(OTel.attributeString(
          'octoai.model.family',
          res.modelFamily!,
        ));
      }
      if (res.quantization != null) {
        extras.add(OTel.attributeString(
          'octoai.model.quantization',
          res.quantization!,
        ));
      }
      if (res.gpu != null) {
        extras.add(OTel.attributeString('octoai.gpu', res.gpu!));
      }
      if (res.streamed != null) {
        extras.add(OTel.attributeBool('octoai.streamed', res.streamed!));
      }
      if (res.promptTokens != null) {
        extras.add(OTel.attributeInt(
          'octoai.usage.prompt_tokens',
          res.promptTokens!,
        ));
      }
      if (res.completionTokens != null) {
        extras.add(OTel.attributeInt(
          'octoai.usage.completion_tokens',
          res.completionTokens!,
        ));
      }
      if (res.totalTokens != null) {
        extras.add(OTel.attributeInt(
          'octoai.usage.total_tokens',
          res.totalTokens!,
        ));
      }
      if (res.tokensPerSecond != null) {
        extras.add(OTel.attributeDouble(
          'octoai.usage.tokens_per_second',
          res.tokensPerSecond!,
        ));
      }
      if (res.timeToFirstTokenMs != null) {
        extras.add(OTel.attributeInt(
          'octoai.usage.ttft_ms',
          res.timeToFirstTokenMs!,
        ));
      }
      if (res.imageSteps != null) {
        extras.add(OTel.attributeInt(
          'octoai.image.steps',
          res.imageSteps!,
        ));
      }
      if (res.imageCount != null) {
        extras.add(OTel.attributeInt(
          'octoai.image.count',
          res.imageCount!,
        ));
      }
      if (res.imageWidth != null) {
        extras.add(OTel.attributeInt(
          'octoai.image.width',
          res.imageWidth!,
        ));
      }
      if (res.imageHeight != null) {
        extras.add(OTel.attributeInt(
          'octoai.image.height',
          res.imageHeight!,
        ));
      }
      if (res.audioSeconds != null) {
        extras.add(OTel.attributeInt(
          'octoai.audio.seconds',
          res.audioSeconds!,
        ));
      }
      if (res.creditsUsed != null) {
        extras.add(OTel.attributeInt(
          'octoai.credits.used',
          res.creditsUsed!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'octoai.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'OctoAI ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'octoai.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(SpanStatusCode.Error, 'OctoAI HTTP ${res.statusCode}');
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
