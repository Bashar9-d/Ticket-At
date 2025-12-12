import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../my_widget/my_colors.dart';
import '../service/supabase_service.dart';

class EventDetailsPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final _service = SupabaseService();
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {

    final DateTime? startTime = widget.event['start_time'] != null
        ? DateTime.parse(widget.event['start_time'])
        : null;
    final DateTime? endTime = widget.event['end_time'] != null
        ? DateTime.parse(widget.event['end_time'])
        : null;

    final String dateString = startTime != null
        ? DateFormat('dd MMMM yyyy').format(startTime)
        : "TBA";

    final String timeString = startTime != null
        ? DateFormat('hh:mm a').format(startTime)
        : "";

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: MyColors.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.share, color: Colors.white),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.event['image_url'] != null
                          ? Image.network(
                              widget.event['image_url'],
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey,
                              child: const Icon(Icons.image, size: 50),
                            ),

                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 20,
                        left: 16,
                        right: 16,
                        child: Text(
                          widget.event['title'] ?? "No Title",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: MyColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: MyColors.primary,
                    tabs: const [
                      Tab(text: "About"),
                      Tab(text: "Contact"),
                      Tab(text: "Reviews"),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildAboutTab(dateString, timeString, startTime, endTime),

              _buildContactTab(),

              _buildReviewsTab(),
            ],
          ),
        ),

        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isBooking
                ? null
                : () async {
                    setState(() => _isBooking = true);
                    try {
                      await _service.bookEvent(widget.event['id']);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Your ticket has been successfully booked! ✅"),
                            backgroundColor: Colors.green,
                          ),
                        );

                      }
                    } catch (e) {
                      if (context.mounted) {
                        String errorMsg = e.toString().contains("duplicate")
                            ? "You have already booked this event"
                            : "An error occurred while booking";
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMsg),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isBooking = false);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: _isBooking
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Book now",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutTab(
    String date,
    String time,
    DateTime? start,
    DateTime? end,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Description",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          widget.event['description'] ?? "No description available.",
          style: const TextStyle(color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 20),

        // جدول الوقت
        _buildInfoRow("Start Time", "$date  |  $time"),
        if (end != null)
          _buildInfoRow(
            "End Time",
            DateFormat('dd MMM yyyy | hh:mm a').format(end),
          ),

        const SizedBox(height: 20),

        const Text(
          "Features",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 15,
          runSpacing: 10,
          children: const [
            _FeatureItem(icon: Icons.local_parking, label: "Parking Available"),
            _FeatureItem(icon: Icons.wifi, label: "Free WiFi"),
            _FeatureItem(icon: Icons.fastfood, label: "Beverages"),
            _FeatureItem(icon: Icons.child_care, label: "Children Corner"),
          ],
        ),
      ],
    );
  }

  Widget _buildContactTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildContactItem(
          Icons.location_on,
          "Location",
          widget.event['location'] ?? "No location provided",
        ),
        _buildContactItem(
          Icons.phone,
          "Phone Number",
          widget.event['contact_number'] ?? "N/A",
        ),
        _buildContactItem(
          Icons.message,
          "WhatsApp",
          widget.event['whatsapp'] ?? "N/A",
        ),
        _buildContactItem(
          Icons.email,
          "Email Address",
          widget.event['email'] ?? "N/A",
        ),

        const SizedBox(height: 20),
        const Text("Find us on", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            if (widget.event['social_link'] != null)
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.link, color: MyColors.primary, size: 30),
              ),

            Icon(Icons.facebook, color: MyColors.primary, size: 30),
            const SizedBox(width: 15),
            Icon(Icons.video_library, color: MyColors.primary, size: 30),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: const [
            Text(
              "5.00",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 10),
            Icon(Icons.star, color: Colors.amber),
            Icon(Icons.star, color: Colors.amber),
            Icon(Icons.star, color: Colors.amber),
            Icon(Icons.star, color: Colors.amber),
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 5),
            Text("(5 Reviews)", style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            hintText: "Write your review...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: MyColors.primary,
              side: BorderSide(color: MyColors.primary),
            ),
            child: const Text("Post Review"),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(icon, color: MyColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                value,
                style: TextStyle(
                  color: MyColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: MyColors.primary),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: MyColors.primary)),
      ],
    );
  }
}
