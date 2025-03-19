import 'dart:io';

import 'package:fleather/fleather.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parchment_delta/parchment_delta.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:parchment/codecs.dart';

class Editor extends StatefulWidget {
  final Function onChange;
  final String initialValue;
  final bool readOnly;

  Editor({Key? key, required this.onChange, required this.initialValue, required this.readOnly}) : super(key: key);

  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final FocusNode _focusNode = FocusNode();
  FleatherController? _controller;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) BrowserContextMenu.disableContextMenu();
    _initController();
  }

  @override
  void dispose() {
    super.dispose();
    if (kIsWeb) BrowserContextMenu.enableContextMenu();
  }

  Future<void> _initController() async {

    const codec = ParchmentHtmlCodec();

    final ParchmentDocument doc = codec.decode(widget.initialValue);
    _controller = FleatherController(document: doc);

    _controller!.addListener(() {
      var html = codec.encode(_controller!.document);
      widget.onChange(html);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _controller == null
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Container(
                  color: Colors.grey.withAlpha(15),
                  child: FleatherToolbar.basic(controller: _controller!)),
              Divider(height: 1, thickness: 2, color: Colors.grey.shade200),
              Expanded(
                child: Container(
                  color: Colors.grey.withAlpha(15),
                  child: FleatherEditor(
                    readOnly: widget.readOnly,
                    controller: _controller!,
                    focusNode: _focusNode,
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    onLaunchUrl: _launchUrl,
                    maxContentWidth: 800,
                    embedBuilder: _embedBuilder,
                    showCursor: true,
                    spellCheckConfiguration: SpellCheckConfiguration(
                        spellCheckService: DefaultSpellCheckService(),
                        misspelledSelectionColor: Colors.red,
                        misspelledTextStyle:
                            DefaultTextStyle.of(context).style),
                  ),
                ),
              ),
            ],
          );
  }

  Widget _embedBuilder(BuildContext context, EmbedNode node) {
    // if (node.value.type == 'icon') {
    //   final data = node.value.data;
    //   // Icons.rocket_launch_outlined
    //   return Icon(
    //     IconData(int.parse(data['codePoint']), fontFamily: data['fontFamily']),
    //     color: Color(int.parse(data['color'])),
    //     size: 18,
    //   );
    // }

    if (node.value.type == 'image') {
      final sourceType = node.value.data['source_type'];
      ImageProvider? image;
      if (sourceType == 'assets') {
        image = AssetImage(node.value.data['source']);
      } else if (sourceType == 'file') {
        image = FileImage(File(node.value.data['source']));
      } else if (sourceType == 'url') {
        image = NetworkImage(node.value.data['source']);
      }
      if (image != null) {
        return Padding(
          // Caret takes 2 pixels, hence not symmetric padding values.
          padding: const EdgeInsets.only(left: 4, right: 2, top: 2, bottom: 2),
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              image: DecorationImage(image: image, fit: BoxFit.cover),
            ),
          ),
        );
      }
    }

    return defaultFleatherEmbedBuilder(context, node);
  }

  void _launchUrl(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    final _canLaunch = await canLaunchUrl(uri);
    if (_canLaunch) {
      await launchUrl(uri);
    }
  }
}

/// This is an example insert rule that will insert a new line before and
/// after inline image embed.
class ForceNewlineForInsertsAroundInlineImageRule extends InsertRule {
  @override
  Delta? apply(Delta document, int index, Object data) {
    if (data is! String) return null;

    final iter = DeltaIterator(document);
    final previous = iter.skip(index);
    final target = iter.next();
    final cursorBeforeInlineEmbed = _isInlineImage(target.data);
    final cursorAfterInlineEmbed =
        previous != null && _isInlineImage(previous.data);

    if (cursorBeforeInlineEmbed || cursorAfterInlineEmbed) {
      final delta = Delta()..retain(index);
      if (cursorAfterInlineEmbed && !data.startsWith('\n')) {
        delta.insert('\n');
      }
      delta.insert(data);
      if (cursorBeforeInlineEmbed && !data.endsWith('\n')) {
        delta.insert('\n');
      }
      return delta;
    }
    return null;
  }

  bool _isInlineImage(Object data) {
    if (data is EmbeddableObject) {
      return data.type == 'image' && data.inline;
    }
    if (data is Map) {
      return data[EmbeddableObject.kTypeKey] == 'image' &&
          data[EmbeddableObject.kInlineKey];
    }
    return false;
  }
}
