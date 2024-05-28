import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total rankings'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              icon: const Icon(Icons.filter_list),
              underline: const SizedBox(),
              items: ['All', 'Option 2', 'Option 3'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey[300],
                    ),
                    child: const Text('Day'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey[300],
                    ),
                    child: const Text('Week'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey[300],
                    ),
                    child: const Text('Month'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                const Text(
                  'May 28',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Daily Top 3',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRankingCard('1', 'p', '05:33:31', Colors.yellow),
                _buildRankingCard('2', 'o', '05:28:26', Colors.grey),
                _buildRankingCard('3', 's', '04:54:49', Colors.brown.shade300),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              'Studying 740 people   Today 2,163 people',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16.0),
            _buildRankingItem('1', 'e', 'g', '05:33:31'),
            _buildRankingItem('2', 'q', 's', '05:28:26'),
            _buildRankingItem('3', 'z', 'q', '04:54:49'),
            _buildRankingItem('4', 'y', 'r', '04:42:30'),
            _buildRankingItem('5', 'x', 't', '04:38:56'),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingCard(String rank, String name, String time, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24.0,
          backgroundColor: color,
          child: Text(
            rank,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          name,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRankingItem(
      String rank, String name, String category, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12.0,
            backgroundColor: Colors.red,
            child: Text(
              rank,
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8.0),
          Icon(
            Icons.headset_mic,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8.0),
          Icon(
            Icons.desktop_windows,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }
}
