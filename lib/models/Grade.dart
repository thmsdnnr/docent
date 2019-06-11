import "dart:math";

class Grade {
  Grade(
      {this.id,
      this.flashCardId,
      this.reps = 0,
      this.easiness = 2.5,
      this.interval = 1,
      this.nextPracticeTimestamp});

  int id;
  int flashCardId;
  int reps;
  double easiness;
  int interval;
  int nextPracticeTimestamp;

  String toString() {
    return "$id $flashCardId $reps $easiness $interval $nextPracticeTimestamp";
  }

  Grade updateGradeWithQuality(int quality) {
    int newReps = this.reps + 1;
    if (quality < 3) {
      newReps = 0;
    }
    double newEasiness = max(1.3,
        easiness + 0.1 - (5.0 - quality) * (0.08 + (5.0 - quality) * 0.02));
    int newInterval = 0;
    if (newReps < 2) {
      newInterval = 1;
    } else if (newReps == 2) {
      newInterval = 6;
    } else {
      newInterval = (newInterval * newEasiness).round();
    }
    DateTime rightNow = DateTime.now().add(Duration(days: interval));
    int newNextPracticeTimestamp = rightNow.millisecondsSinceEpoch;
    return new Grade.fromMap({
      "id": this.id,
      "flashCardId": this.flashCardId,
      "reps": newReps,
      "easiness": newEasiness,
      "interval": newInterval,
      "nextPracticeTimestamp": newNextPracticeTimestamp,
    });
  }

  factory Grade.fromMap(Map<String, dynamic> json) => new Grade(
        id: json["id"],
        flashCardId: json["flashCardId"],
        reps: json["reps"],
        easiness: json["easiness"],
        interval: json["interval"],
        nextPracticeTimestamp: json["nextPracticeTimestamp"],
      );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "flashCardId": flashCardId,
      "reps": reps,
      "easiness": easiness,
      "interval": interval,
      "nextPracticeTimestamp": nextPracticeTimestamp
    };
  }
}
