import 'package:flutter/material.dart';

// No need for flutter_svg anymore as we're using a PNG asset
// import 'package:flutter_svg/flutter_svg.dart';

class NoResultsScreen extends StatelessWidget {
  // Optional: Add parameters for title, description, button text, and press callback
  // if you want this screen to be reusable for different "no results" scenarios.
  final String? title;
  final String? description;
  final String? btnText;
  final VoidCallback? press;

  const NoResultsScreen({
    Key? key, // Use Key? key instead of super.key for constructor
    this.title,
    this.description,
    this.btnText,
    this.press,
  }) : super(key: key); // Pass key to super constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Consider using your project's theme colors instead of hardcoded white
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Search Results"), // Or "No Results" or remove AppBar
        // Consider adding a back button if needed
        // leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Slightly more padding might look better
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the column content vertically
            children: [
              // Removed Spacers for center alignment in the body
              // const Spacer(flex: 2),

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7, // Make image slightly smaller
                child: AspectRatio(
                  aspectRatio: 1, // Keep aspect ratio for consistent sizing
                  // --- MODIFIED: Use Image.asset instead of SvgPicture ---
                  child: Image.asset(
                    // Make sure the path matches where you put default2.png
                    'assets/images/default2.png',
                    fit: BoxFit.contain, // Use contain to ensure the whole image is visible
                  ),
                ),
              ),

              const SizedBox(height: 32), // Add space between image and text

              // Removed Spacer
              // const Spacer(flex: 2),

              // Use the custom ErrorInfo widget
              ErrorInfo(
                // Use provided text or default if not passed
                title: title ?? "No Results!",
                description: description ??
                    "We couldn't find any matches for your search. Try using different terms or browse our categories.",
                btnText: btnText ?? "Search again",
                press: press ?? () {
                   // Default press action if none is provided
                   // You might want to navigate back or clear search
                   Navigator.pop(context);
                },
              ),
              // Removed Spacer
              // const Spacer(), // Add a flexible space at the bottom if needed
            ],
          ),
        ),
      ),
    );
  }
}

// The ErrorInfo widget seems well-designed and reusable, keeping it as is
class ErrorInfo extends StatelessWidget {
  const ErrorInfo({
    Key? key, // Use Key? key instead of super.key
    required this.title,
    required this.description,
    this.button,
    this.btnText,
    required this.press,
  }) : super(key: key); // Pass key to super constructor

  final String title;
  final String description;
  final Widget? button;
  final String? btnText;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
              // Consider using Theme.of(context).textTheme.bodyMedium for consistent styling
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16 * 2.5), // Increased spacing

            // Use custom button if provided, otherwise use the default ElevatedButton
            button ??
                ElevatedButton(
                  onPressed: press,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      // Consider using your project's primary/accent colors instead of hardcoded black/white
                      backgroundColor: Theme.of(context).primaryColor, // Or your theme's button color
                      foregroundColor: Theme.of(context).colorScheme.onPrimary, // Text color based on background
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)))),
                  child: Text(btnText ?? "Retry".toUpperCase()),
                ),
            // const SizedBox(height: 16), // Space after button might not be needed if it's the last element
          ],
        ),
      ),
    );
  }
}

// Removed the noResultsIllistration SVG constant
// const noResultsIllistration = '''...''';