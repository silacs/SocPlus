class Votes {
  int goodVotes;
  int badVotes;
  bool? userVote;
  Votes(this.goodVotes, this.badVotes, this.userVote);
  factory Votes.fromJson(Map<String, dynamic> json) {
    return Votes(json['goodVotes'], json['badVotes'], json['userVote']);
  }
}