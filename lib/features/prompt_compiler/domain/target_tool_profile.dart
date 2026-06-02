import 'package:promptforge/core/database/database.dart';

class CompilerContext {
  final String compiledPromptBody;
  final List<ContextPack> contextPacks;
  final String? outputFormat;
  final String? targetNotes;

  CompilerContext({
    required this.compiledPromptBody,
    required this.contextPacks,
    this.outputFormat,
    this.targetNotes,
  });
}

abstract class TargetToolProfile {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? accentColorHex;

  const TargetToolProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.accentColorHex,
  });

  String format(CompilerContext context);

  static const List<TargetToolProfile> builtIns = [
    GenericProfile(),
    ChatGPTProfile(),
    ClaudeProfile(),
    GeminiProfile(),
    CodexProfile(),
    CursorProfile(),
    NotebookLMProfile(),
    FlowImageProfile(),
    FlowVideoProfile(),
    LocalModelProfile(),
  ];
}

class GenericProfile extends TargetToolProfile {
  const GenericProfile()
      : super(
          id: 'generic',
          name: 'Generic',
          description: 'Standard PromptForge formatting.',
          category: 'Standard',
        );

  @override
  String format(CompilerContext context) {
    final buffer = StringBuffer();

    if (context.contextPacks.isNotEmpty) {
      buffer.writeln('# Context Packs\n');
      for (final pack in context.contextPacks) {
        buffer.writeln('## ${pack.name}\n');
        buffer.writeln('${pack.content}\n');
      }
      buffer.writeln('---');
      buffer.writeln();
    }

    final hasOutputFormat = context.outputFormat != null && context.outputFormat!.trim().isNotEmpty;
    final hasTargetNotes = context.targetNotes != null && context.targetNotes!.trim().isNotEmpty;

    if (context.contextPacks.isNotEmpty || hasOutputFormat || hasTargetNotes) {
      buffer.writeln('# Prompt\n');
    }
    buffer.writeln(context.compiledPromptBody);

    if (hasOutputFormat || hasTargetNotes) {
      buffer.writeln('\n\n# Output Requirements\n');
      if (hasOutputFormat) {
        buffer.writeln(context.outputFormat);
      }
      if (hasTargetNotes) {
        if (hasOutputFormat) buffer.writeln();
        buffer.writeln(context.targetNotes);
      }
    }

    return buffer.toString().trim();
  }
}

class ChatGPTProfile extends TargetToolProfile {
  const ChatGPTProfile()
      : super(
          id: 'chatgpt',
          name: 'ChatGPT',
          description: 'Use clear sections and direct instructions.',
          category: 'LLM',
          accentColorHex: '#10A37F',
        );

  @override
  String format(CompilerContext context) {
    final buffer = StringBuffer();

    if (context.contextPacks.isNotEmpty) {
      buffer.writeln('# Context\n');
      for (final pack in context.contextPacks) {
        buffer.writeln('${pack.content}\n');
      }
    }

    buffer.writeln('# Task\n');
    buffer.writeln(context.compiledPromptBody);

    final hasOutputFormat = context.outputFormat != null && context.outputFormat!.trim().isNotEmpty;
    final hasTargetNotes = context.targetNotes != null && context.targetNotes!.trim().isNotEmpty;

    if (hasOutputFormat || hasTargetNotes) {
      buffer.writeln('\n\n# Output Requirements\n');
      if (hasOutputFormat) buffer.writeln(context.outputFormat);
      if (hasTargetNotes) {
        if (hasOutputFormat) buffer.writeln();
        buffer.writeln(context.targetNotes);
      }
    }

    return buffer.toString().trim();
  }
}

class ClaudeProfile extends TargetToolProfile {
  const ClaudeProfile()
      : super(
          id: 'claude',
          name: 'Claude',
          description: 'Use XML tags for strong role/context framing.',
          category: 'LLM',
          accentColorHex: '#D97757',
        );

  @override
  String format(CompilerContext context) {
    final buffer = StringBuffer();

    buffer.writeln('You are helping with the following task.\n');

    if (context.contextPacks.isNotEmpty) {
      buffer.writeln('<context>');
      for (final pack in context.contextPacks) {
        buffer.writeln(pack.content);
        buffer.writeln();
      }
      buffer.writeln('</context>\n');
    }

    buffer.writeln('<task>\n${context.compiledPromptBody}\n</task>');

    final hasOutputFormat = context.outputFormat != null && context.outputFormat!.trim().isNotEmpty;
    final hasTargetNotes = context.targetNotes != null && context.targetNotes!.trim().isNotEmpty;

    if (hasOutputFormat || hasTargetNotes) {
      buffer.writeln('\n<output_requirements>');
      if (hasOutputFormat) buffer.writeln(context.outputFormat);
      if (hasTargetNotes) {
        if (hasOutputFormat) buffer.writeln();
        buffer.writeln(context.targetNotes);
      }
      buffer.writeln('</output_requirements>');
    }

    return buffer.toString().trim();
  }
}

class GeminiProfile extends TargetToolProfile {
  const GeminiProfile()
      : super(
          id: 'gemini',
          name: 'Gemini',
          description: 'Concise structured sections for Gemini.',
          category: 'LLM',
          accentColorHex: '#1A73E8',
        );

  @override
  String format(CompilerContext context) {
    // Very similar to Generic/ChatGPT but we can adapt it if needed.
    // The prompt says "Use concise structured sections and multimodal-friendly wording where appropriate."
    final buffer = StringBuffer();
    
    if (context.contextPacks.isNotEmpty) {
      buffer.writeln('## Background Context\n');
      for (final pack in context.contextPacks) {
        buffer.writeln(pack.content);
        buffer.writeln();
      }
    }

    buffer.writeln('## Primary Request\n');
    buffer.writeln(context.compiledPromptBody);

    final hasOutputFormat = context.outputFormat != null && context.outputFormat!.trim().isNotEmpty;
    final hasTargetNotes = context.targetNotes != null && context.targetNotes!.trim().isNotEmpty;

    if (hasOutputFormat || hasTargetNotes) {
      buffer.writeln('\n\n## Constraints & Output Rules\n');
      if (hasOutputFormat) buffer.writeln(context.outputFormat);
      if (hasTargetNotes) {
        if (hasOutputFormat) buffer.writeln();
        buffer.writeln(context.targetNotes);
      }
    }

    return buffer.toString().trim();
  }
}

class CodexProfile extends TargetToolProfile {
  const CodexProfile()
      : super(
          id: 'codex',
          name: 'Codex',
          description: 'Implementation-focused wording.',
          category: 'Coding',
        );

  @override
  String format(CompilerContext context) {
    final buffer = StringBuffer();
    
    buffer.writeln('Please implement the following changes. Make minimal surgical changes, run tests, report files changed, and do not invent APIs.\n');
    
    if (context.contextPacks.isNotEmpty) {
      buffer.writeln('# Codebase Context\n');
      for (final pack in context.contextPacks) {
        buffer.writeln(pack.content);
        buffer.writeln();
      }
    }

    buffer.writeln('# Implementation Request\n');
    buffer.writeln(context.compiledPromptBody);

    final hasOutputFormat = context.outputFormat != null && context.outputFormat!.trim().isNotEmpty;
    final hasTargetNotes = context.targetNotes != null && context.targetNotes!.trim().isNotEmpty;

    if (hasOutputFormat || hasTargetNotes) {
      buffer.writeln('\n\n# Technical Requirements\n');
      if (hasOutputFormat) buffer.writeln(context.outputFormat);
      if (hasTargetNotes) {
        if (hasOutputFormat) buffer.writeln();
        buffer.writeln(context.targetNotes);
      }
    }

    return buffer.toString().trim();
  }
}

class CursorProfile extends TargetToolProfile {
  const CursorProfile()
      : super(
          id: 'cursor',
          name: 'Cursor',
          description: 'IDE-oriented implementation instructions.',
          category: 'Coding',
        );

  @override
  String format(CompilerContext context) {
    final buffer = StringBuffer();
    
    buffer.writeln('Inspect the current code and preserve existing architecture. Apply localized changes and explain them briefly.\n');
    
    if (context.contextPacks.isNotEmpty) {
      buffer.writeln('## Context\n');
      for (final pack in context.contextPacks) {
        buffer.writeln(pack.content);
        buffer.writeln();
      }
    }

    buffer.writeln('## Task\n');
    buffer.writeln(context.compiledPromptBody);

    final hasOutputFormat = context.outputFormat != null && context.outputFormat!.trim().isNotEmpty;
    final hasTargetNotes = context.targetNotes != null && context.targetNotes!.trim().isNotEmpty;

    if (hasOutputFormat || hasTargetNotes) {
      buffer.writeln('\n\n## Output Rules\n');
      if (hasOutputFormat) buffer.writeln(context.outputFormat);
      if (hasTargetNotes) {
        if (hasOutputFormat) buffer.writeln();
        buffer.writeln(context.targetNotes);
      }
    }

    return buffer.toString().trim();
  }
}

class NotebookLMProfile extends TargetToolProfile {
  const NotebookLMProfile()
      : super(
          id: 'notebooklm',
          name: 'NotebookLM',
          description: 'Source-grounded behavior for NotebookLM.',
          category: 'Research',
        );

  @override
  String format(CompilerContext context) {
    final buffer = StringBuffer();
    
    buffer.writeln('Use only the uploaded/source material when answering. If information is not in the sources, say so.\n');
    
    if (context.contextPacks.isNotEmpty) {
      buffer.writeln('# Additional Context\n');
      for (final pack in context.contextPacks) {
        buffer.writeln(pack.content);
        buffer.writeln();
      }
    }

    buffer.writeln('# Query\n');
    buffer.writeln(context.compiledPromptBody);

    final hasOutputFormat = context.outputFormat != null && context.outputFormat!.trim().isNotEmpty;
    final hasTargetNotes = context.targetNotes != null && context.targetNotes!.trim().isNotEmpty;

    if (hasOutputFormat || hasTargetNotes) {
      buffer.writeln('\n\n# Output Formatting\n');
      if (hasOutputFormat) buffer.writeln(context.outputFormat);
      if (hasTargetNotes) {
        if (hasOutputFormat) buffer.writeln();
        buffer.writeln(context.targetNotes);
      }
    }

    return buffer.toString().trim();
  }
}

class FlowImageProfile extends TargetToolProfile {
  const FlowImageProfile()
      : super(
          id: 'flow-image',
          name: 'Flow Image',
          description: 'Produce concise visual prompt formatting.',
          category: 'Generation',
        );

  @override
  String format(CompilerContext context) {
    final buffer = StringBuffer();
    
    // For images, we just concatenate neatly without academic prose.
    buffer.writeln(context.compiledPromptBody);

    if (context.contextPacks.isNotEmpty) {
      buffer.writeln();
      for (final pack in context.contextPacks) {
        buffer.writeln(pack.content);
      }
    }

    final hasOutputFormat = context.outputFormat != null && context.outputFormat!.trim().isNotEmpty;
    final hasTargetNotes = context.targetNotes != null && context.targetNotes!.trim().isNotEmpty;

    if (hasOutputFormat || hasTargetNotes) {
      buffer.writeln();
      if (hasOutputFormat) buffer.writeln(context.outputFormat);
      if (hasTargetNotes) {
        if (hasOutputFormat) buffer.writeln();
        buffer.writeln(context.targetNotes);
      }
    }

    return buffer.toString().trim();
  }
}

class FlowVideoProfile extends TargetToolProfile {
  const FlowVideoProfile()
      : super(
          id: 'flow-video',
          name: 'Flow Video',
          description: 'Video/motion prompt formatting.',
          category: 'Generation',
        );

  @override
  String format(CompilerContext context) {
    return const FlowImageProfile().format(context); // Share same logic for now
  }
}

class LocalModelProfile extends TargetToolProfile {
  const LocalModelProfile()
      : super(
          id: 'local-model',
          name: 'Local Model',
          description: 'Shorter wrapper avoiding complex nested instructions.',
          category: 'Local',
        );

  @override
  String format(CompilerContext context) {
    final buffer = StringBuffer();
    
    if (context.contextPacks.isNotEmpty) {
      for (final pack in context.contextPacks) {
        buffer.writeln(pack.content);
        buffer.writeln();
      }
    }

    buffer.writeln(context.compiledPromptBody);

    final hasOutputFormat = context.outputFormat != null && context.outputFormat!.trim().isNotEmpty;
    final hasTargetNotes = context.targetNotes != null && context.targetNotes!.trim().isNotEmpty;

    if (hasOutputFormat || hasTargetNotes) {
      buffer.writeln();
      if (hasOutputFormat) buffer.writeln(context.outputFormat);
      if (hasTargetNotes) {
        if (hasOutputFormat) buffer.writeln();
        buffer.writeln(context.targetNotes);
      }
    }

    return buffer.toString().trim();
  }
}
