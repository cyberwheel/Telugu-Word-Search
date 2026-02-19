class Word {
  final String text;
  final String hint;
  bool found;
  bool hinted;

  Word({
    required this.text,
    required this.hint,
    this.found = false,
    this.hinted = false,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      text: json['text'] as String,
      hint: json['hint'] as String,
      found: json['found'] as bool? ?? false,
      hinted: json['hinted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'hint': hint,
      'found': found,
      'hinted': hinted,
    };
  }

  Word copyWith({
    String? text,
    String? hint,
    bool? found,
    bool? hinted,
  }) {
    return Word(
      text: text ?? this.text,
      hint: hint ?? this.hint,
      found: found ?? this.found,
      hinted: hinted ?? this.hinted,
    );
  }
}
