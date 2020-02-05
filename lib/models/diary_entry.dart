
// class that defines a Diary Entry

class Entry {
  final String id;
  final String day;
  final String month;
  final String year;
  final String hour;
  final String minutes;
  final String currentValue;
  final String unitsInjected;
  final String sort;
  final String notes;
  final bool isInjected;
  final bool meal;
  final bool sport;
  final bool bed;

  Entry({
    this.id,
    this.day,
    this.month,
    this.year,
    this.hour,
    this.minutes,
    this.currentValue,
    this.unitsInjected,
    this.sort,
    this.notes,
    this.isInjected,
    this.meal,
    this.sport,
    this.bed, 
  });

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'day': day,
      'month': month,
      'year': year,
      'hour': hour,
      'minutes' : minutes,
      'currentValue' : currentValue,
      'unitsInjected' : unitsInjected,
      'insulin' : sort,
      'notes' : notes,
      'isInjected' : isInjected,
      'meal' : meal,
      'sport' : sport,
      'bed' : bed,
    };
  }
}

