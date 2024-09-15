import 'package:flutter/material.dart';
import '../../../models/barbershop.dart';
import 'PhotoTab.dart';
import 'PriceTab.dart';
import 'ReviewTab.dart';

class BarbershopDetailScreen extends StatelessWidget {
  final Barbershop barbershop;

  BarbershopDetailScreen({required this.barbershop});

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(barbershop.name ?? 'Barbershop Detail'),
          bottom: TabBar(
            tabs: [
              Tab(text: '홈'),
              Tab(text: '가격'),
              Tab(text: '리뷰'),
              Tab(text: '사진'),
            ],
          ),
        ),
        body: Container(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: barbershop.thumUrl == null || barbershop.thumUrl?.isEmpty == true
                      ? Image.asset(
                    'assets/barbershop02.jpg',  // Default image if thumUrl is null or empty
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    barbershop.thumUrl ?? '',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/barbershop02.jpg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
            ],
            body: TabBarView(
              children: [
                // Home Tab
                Center(child: Text('Welcome to ${barbershop.name ?? ''}')),

                // Price Tab
                PriceTab(menuInfo: barbershop.menuInfo),

                // Review Tab
               // ReviewTab(barbershop: barbershop),
                // Inside your BarbershopDetailScreen widget
                ReviewTab( contextList: 'barbershop', microReviewList: barbershop.microReview, barbershopId: '',),


                PhotoTab(
                  homePage: barbershop.homePage ?? '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





