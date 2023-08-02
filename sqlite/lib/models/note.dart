class Note {
  int? _id;
  String _title = '';
  String _description = '';
  String _date = '';
  int _priority = 1;

  Note(this._title, this._priority, this._description, this._date);

  Note.withId(
      this._id, this._title, this._date, this._priority, this._description);

  int? get id => _id;
  String get title => _title;
  String get description => _description;
  String get date => _date;
  int get priority => _priority;

  set title(String newTitle) {
    if (newTitle.length <= 200) {
      this._title = newTitle;
    }
  }

  set description(String newDescription) {
    if (newDescription.length <= 500) {
      this._description = newDescription;
    }
  }

  set priority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 2) {
      this._priority = newPriority;
    }
  }

  set date(String newDate) {
    this._date = newDate;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'description': description,
      'priority': priority,
      'date': date,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  Note.fromMapObject(Map<String, dynamic> map)
      : _id = map['id'],
        _title = map['title'] ?? '',
        _description = map['description'] ?? '',
        _priority = map['priority'] ?? 0,
        _date = map['date'] ?? '';
}
