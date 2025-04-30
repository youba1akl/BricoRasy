import 'package:flutter/material.dart';

class CustomContainerAnn extends StatelessWidget {
  const CustomContainerAnn({
    super.key,
    this.title,
    this.description,
    this.localisation,
    this.img,
    this.page,
  });

  final String? title;
  final String? description;
  final String? localisation;
  final Image? img;
  final Widget? page;

  String capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isNotEmpty) {
            return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
          }
          return '';
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page!),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.black38, width: 0.5)),
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.black,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child:
                      img ??
                      Image.asset(
                        'assets/images/placeholder.png',
                        fit: BoxFit.cover,
                      ),
                ),
              ),
              const SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capitalizeWords(title ?? 'No Title'),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    description ?? 'No description available.',
                    style: const TextStyle(color: Colors.black54, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    capitalizeWords(localisation ?? 'No Location'),
                    style: const TextStyle(color: Colors.black45, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
