import 'package:flutter/material.dart';
// Removed flutter_svg import

// --- Dummy Data for BricoRasy Services ---
class BricoleService {
  final String name;
  final String imagePath;
  final double rating;
  final int numOfRating;
  final int durationMinutes;
  final List<String> categories;
  final bool isPriceAvailable;

  BricoleService({
    required this.name,
    required this.imagePath,
    required this.rating,
    required this.numOfRating,
    required this.durationMinutes,
    required this.categories,
    required this.isPriceAvailable,
  });
}

final List<BricoleService> dummyServices = [
  BricoleService(
    name: "Service Nettoyage Expert",
    imagePath: 'assets/images/default2.png',
    rating: 4.8,
    numOfRating: 350,
    durationMinutes: 60,
    categories: ["Nettoyage", "Entretien"],
    isPriceAvailable: true,
  ),
  BricoleService(
    name: "Plombier Rapide & Fiable",
    imagePath: 'assets/images/default2.png',
    rating: 4.5,
    numOfRating: 120,
    durationMinutes: 45,
    categories: ["Plomberie", "Réparation"],
    isPriceAvailable: true,
  ),
  BricoleService(
    name: "Électricien Certifié",
    imagePath: 'assets/images/default2.png',
    rating: 4.9,
    numOfRating: 500,
    durationMinutes: 90,
    categories: ["Électricité", "Installation", "Dépannage"],
    isPriceAvailable: true,
  ),
  BricoleService(
    name: "Peintre Décorateur",
    imagePath: 'assets/images/default2.png',
    rating: 4.7,
    numOfRating: 210,
    durationMinutes: 180,
    categories: ["Peinture", "Décoration"],
    isPriceAvailable: false,
  ),
  BricoleService(
    name: "Jardinier Paysagiste",
    imagePath: 'assets/images/default2.png',
    rating: 4.6,
    numOfRating: 180,
    durationMinutes: 120,
    categories: ["Jardinage", "Aménagement Extérieur"],
    isPriceAvailable: true,
  ),
];
// --- End Dummy Data ---


class BricoleScreen extends StatefulWidget {
  const BricoleScreen({super.key});

  @override
  State<BricoleScreen> createState() => _BricoleScreenState();
}

class _BricoleScreenState extends State<BricoleScreen> {
  bool _showSearchResults = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void simulateSearch(String query) {
     if (query.length < 2 && query.isNotEmpty) { // Minimum length for search
        // Don't trigger search until a certain length is reached
        return;
     }

     if (query.isEmpty) {
        // If query is empty, show top services again
        if (mounted) {
            setState(() {
               _showSearchResults = false;
               // TODO: Maybe reload dummyServices or show a different default list
            });
        }
        return;
     }


    if (mounted) {
       setState(() {
         _isLoading = true;
       });
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showSearchResults = true;
          _isLoading = false;
          // TODO: Implement actual filtering or fetching based on 'query'
          // For demo, we just change state and title
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Search', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),

              SearchForm(onSearch: simulateSearch),
              const SizedBox(height: 16),

              const Divider(thickness: 1),
              const SizedBox(height: 16),

              Text(
                  _showSearchResults ? "Search Results" : "Top Services",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: _isLoading ? 2 : dummyServices.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _isLoading
                        ? const ServiceCardScalton()
                        : ServiceInfoBigCard(
                            service: dummyServices[index],
                            press: () {
                              print('Tapped on ${dummyServices[index].name}');
                              // TODO: Navigate to service detail screen
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Renamed and Modified Service Card Widget ---
class ServiceInfoBigCard extends StatelessWidget {
  final BricoleService service;
  final VoidCallback press;

  const ServiceInfoBigCard({
    Key? key,
    required this.service,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get a slightly muted color for icons and text
    final mutedColor = Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);

    return InkWell(
      onTap: press,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ServiceImageDisplay(imagePath: service.imagePath),
          const SizedBox(height: 8),
          Text(service.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          CategoriesDisplay(categories: service.categories),
          const SizedBox(height: 4),
          Row(
            children: [
              RatingDisplay(rating: service.rating, numOfRating: service.numOfRating),
              const SizedBox(width: 8),

              // --- MODIFIED: Replaced SvgPicture with Icon ---
              Icon(
                Icons.timer_outlined, // Use a timer icon
                size: 18,
                color: mutedColor,
              ),
              const SizedBox(width: 4),
              Text(
                "${service.durationMinutes} Min",
                style: Theme.of(context).textTheme.labelSmall,
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: SmallDot(),
              ),

              // --- MODIFIED: Replaced SvgPicture with Icon ---
              Icon(
                Icons.attach_money, // Use a money/price icon
                 size: 18,
                 color: mutedColor,
              ),
              const SizedBox(width: 4),
              Text(service.isPriceAvailable ? "Price Available" : "Request Quote",
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}


// --- Helper Widgets (Same as before) ---

class CategoriesDisplay extends StatelessWidget {
  final List<String> categories;

  const CategoriesDisplay({Key? key, required this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      categories.join(" • "),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
         color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
      ),
    );
  }
}

class RatingDisplay extends StatelessWidget {
  final double rating;
  final int numOfRating;

  const RatingDisplay({Key? key, required this.rating, required this.numOfRating}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: Colors.amber, size: 18),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          "($numOfRating+)",
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class SmallDot extends StatelessWidget {
  const SmallDot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 4,
      width: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}

class ServiceImageDisplay extends StatelessWidget {
  final String imagePath;

  const ServiceImageDisplay({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.81,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}


// --- Skeleton Loader Widgets (Same as before) ---
class ServiceCardScalton extends StatelessWidget {
  const ServiceCardScalton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ServiceImageScalton(),
        const SizedBox(height: 16),
        ScaltonLine(
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        const SizedBox(height: 16),
        const ScaltonLine(),
        const SizedBox(height: 16),
        ScaltonLine(
          width: MediaQuery.of(context).size.width * 0.6,
        ),
      ],
    );
  }
}

class ServiceImageScalton extends StatelessWidget {
  const ServiceImageScalton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.81,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.08),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}

class ScaltonLine extends StatelessWidget {
  const ScaltonLine({
    Key? key,
    this.height = 15,
    this.width = double.infinity,
  }) : super(key: key);
  final double height, width;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Colors.black.withOpacity(0.08),
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    Key? key,
    this.isActive = false,
    this.activeColor = const Color(0xFF22A45D),
    this.inActiveColor = const Color(0xFF868686),
  }) : super(key: key);
  final bool isActive;
  final Color activeColor, inActiveColor;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 5,
      width: isActive ? 16 : 8,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inActiveColor.withOpacity(0.25),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
    );
  }
}


// --- Search Form Widget (Adapted to use Icon) ---
class SearchForm extends StatefulWidget {
  final Function(String) onSearch;

  const SearchForm({Key? key, required this.onSearch}) : super(key: key);

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: _searchController,
        onChanged: (value) {
           // Optionally trigger search while typing
           // You might want to debounce this to avoid excessive calls
           // if (value.length >= 2 || value.isEmpty) {
           //   widget.onSearch(value);
           // }
        },
        onFieldSubmitted: (value) {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            widget.onSearch(value);
          }
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Please enter a service or provider name";
          }
           // Optional: Add minimum length validation
           // if (value.trim().length < 2) {
           //   return "Query must be at least 2 characters long";
           // }
          return null;
        },
        style: Theme.of(context).textTheme.labelLarge,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "Search for services or providers",
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          // --- MODIFIED: Replaced SvgPicture with Icon ---
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0), // Slightly more padding for Icon
            child: Icon(
              Icons.search, // Standard search icon
              color: const Color(0xFF868686), // Use the same color as in the SVG
              size: 24, // Default size for Icon
            ),
          ),
          border: OutlineInputBorder(
             borderRadius: BorderRadius.circular(8),
             borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }
}

// --- Removed SVG Icon Constants ---
// const searchIconSvg = '''...''';
// const clockIconSvg = '''...''';
// const deliveryIconSvg = '''...''';

// Removed other potentially unused SVG constants