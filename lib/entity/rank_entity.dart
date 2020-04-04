class RankEntity {
	int level;
	int rank;
	int userId;
	int coinCount;
	String username;

	RankEntity({this.level, this.rank, this.userId, this.coinCount, this.username});

	RankEntity.fromJson(Map<String, dynamic> json) {
		level = json['level'];
		rank = json['rank'];
		userId = json['userId'];
		coinCount = json['coinCount'];
		username = json['username'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['level'] = this.level;
		data['rank'] = this.rank;
		data['userId'] = this.userId;
		data['coinCount'] = this.coinCount;
		data['username'] = this.username;
		return data;
	}
}
