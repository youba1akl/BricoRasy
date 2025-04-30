import '../../widgets/poste_custom.dart';
import '../../widgets/tarif_custom.dart';
import 'package:flutter/material.dart';

class Artisanprofilscreen extends StatefulWidget {
  const Artisanprofilscreen({super.key, this.username, this.job, this.loc, this.rating, this.like, this.img});
  final String? username;
  final String? job;
  final String? loc;
  final String? rating;
  final String? like;
  final Image? img;


  @override
  State<Artisanprofilscreen> createState() => _ArtisanprofilscreenState();
}

class _ArtisanprofilscreenState extends State<Artisanprofilscreen> {
  String currentView = 'postes';

  void toggleView(String view) {
    setState(() {
      currentView = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Container(
              decoration: const BoxDecoration(
                color: Color(0XFF3D4C5E),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 260,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(color: Color(0XFFFAFBFA)),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: ClipOval(
                          child: widget.img ??
                            Image.asset(
                            'assets/images/profil.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.username!,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.job!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    Container(
                      height: 55,
                      margin: EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.star_border),
                                  Text(widget.rating!),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    width: 1,
                                    color: Colors.black,
                                  ),
                                  left: BorderSide(
                                    width: 1,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.location_on_outlined),
                                    Text(widget.loc!),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.favorite_border),
                                  Text(widget.like!),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 250,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2.0,
                      spreadRadius: 1.0,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 5,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0XFF19A45F),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.phone,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Appeler',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          fit: FlexFit.tight,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  width: 2,
                                  color: Colors.black,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.forum_outlined,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Message',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              backgroundColor: Colors.white,
                              builder:
                                  (context) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(
                                          Icons.bookmark_border,
                                        ),
                                        title: const Text('Saved'),
                                        onTap: () => Navigator.pop(context),
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                          Icons.comment_outlined,
                                        ),
                                        title: const Text('Votre Avis'),
                                        onTap: () => Navigator.pop(context),
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                          Icons.share_outlined,
                                        ),
                                        title: const Text('Partager'),
                                        onTap: () => Navigator.pop(context),
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                          Icons.flag_outlined,
                                          color: Colors.red,
                                        ),
                                        title: const Text(
                                          'Signaler',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onTap: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 2, color: Colors.black),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                            child: const Icon(
                              Icons.keyboard_control,
                              size: 25,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 3,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            width: 1.5,
                            color: const Color(0XFF102542),
                          ),
                        ),
                        child: Text(
                          'Catalogue',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0XFF102542),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TarifCustom(title: 'Site Web', prix: '7000'),
                    TarifCustom(title: 'Site Web', prix: '7000'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        buildToggleButton('postes', 'Poste'),
                        const SizedBox(width: 5),
                        buildToggleButton('avis', 'Avis'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (currentView == 'postes') ...[
                      PosteCustom(
                        img: Image.asset('assets/images/E02.png'),
                        aime: '30',
                        comment: '23',
                      ),
                      PosteCustom(
                        aime: '30',
                        comment: '40',
                      ),
                      PosteCustom(
                        img: Image.asset('assets/images/E02.png'),
                        aime: '64',
                        comment: '40',
                      ),
                      PosteCustom(
                        img: Image.asset('assets/images/E02.png'),
                        aime: '64',
                        comment: '40',
                      ),
                      PosteCustom(
                        img: Image.asset('assets/images/E02.png'),
                        aime: '64',
                        comment: '40',
                      ),
                      PosteCustom(
                        img: Image.asset('assets/images/E02.png'),
                        aime: '64',
                        comment: '40',
                      ),
                      PosteCustom(
                        img: Image.asset('assets/images/E02.png'),
                        aime: '30',
                        comment: '64',
                      ),
                      PosteCustom(
                        aime: '30',
                        comment: '23',
                      ),
                    ] else if (currentView == 'avis') ...[
                      PosteCustom(
                        img: Image.asset('assets/images/E02.png'),
                        aime: '30',
                        comment: '23',
                      ),
                      PosteCustom(
                        img: Image.asset('assets/images/E02.png'),
                        aime: '30',
                        comment: '23',
                      ),
                      PosteCustom(
                        img: Image.asset('assets/images/E02.png'),
                        aime: '30',
                        comment: '23',
                      ),
                      PosteCustom(
                        img: Image.asset('assets/images/E02.png'),
                        aime: '30',
                        comment: '23',
                      ),
                      PosteCustom(
                        img: Image.asset('assets/images/E02.png'),
                        aime: '30',
                        comment: '23',
                      ),
                      PosteCustom(
                        img: Image.asset('assets/images/E02.png'),
                        aime: '30',
                        comment: '23',
                      ),
                      PosteCustom(
                        img: Image.asset('assets/images/E02.png'),
                        aime: '30',
                        comment: '23',
                      ),
                      PosteCustom(
                        img: Image.asset('assets/images/E02.png'),
                        aime: '30',
                        comment: '23',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bouton dynamique
  Widget buildToggleButton(String viewKey, String label) {
    bool isSelected = currentView == viewKey;
    return GestureDetector(
      onTap: () => toggleView(viewKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0XFF102542) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 1.5, color: const Color(0XFF102542)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0XFF102542),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
