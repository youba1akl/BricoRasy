import 'package:flutter/material.dart';

class customScaffold_artisan extends StatefulWidget {
  const customScaffold_artisan({super.key});

  @override
  State<customScaffold_artisan> createState() => _customScaffold_artisanState();
}

class _customScaffold_artisanState extends State<customScaffold_artisan> {
  int ind = 0;
  bool rempli = false;

  void remplissageDeEtoile() {
    setState(() {
      if (!rempli) {
        rempli = true;
        ind++;
      } else {
        rempli = false;
        ind--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF145FD6), Color(0xFF1E81CE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image container
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/Iconos gratuitos de Lenguaje De Codificación diseñados por Flat Icons.jpg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "John Doe",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  "Macon ",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  "Localisation: Bejaia",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: remplissageDeEtoile,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(0, 0),
                  ),
                  child: Icon(
                    rempli ? Icons.star : Icons.star_border,
                    size: 28,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ind.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
