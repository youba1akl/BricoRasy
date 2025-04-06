import 'package:bricorasy/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';

class Thermescreen extends StatelessWidget {
  const Thermescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "📜 Termes et Conditions d'Utilisation",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),

                    Text(
                      "1. Présentation de l’Application",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Cette application permet aux utilisateurs de :\n"
                      "- Publier ou consulter des annonces de bricolage.\n"
                      "- Proposer ou rechercher des projets professionnels.\n"
                      "- Mettre en location ou louer des objets.\n"
                      "- Chercher des artisans et les contacter directement.",
                    ),
                    SizedBox(height: 16),

                    Text(
                      "2. Accès et Inscription",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "L’utilisation de certaines fonctionnalités nécessite la création d’un compte. "
                      "Vous devez fournir des informations exactes, à jour et complètes. "
                      "Vous êtes responsable de la confidentialité de votre compte et de votre mot de passe.",
                    ),
                    SizedBox(height: 16),

                    Text(
                      "3. Utilisation Acceptable",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Les utilisateurs s’engagent à ne pas publier de contenus illicites, mensongers, offensants ou frauduleux. "
                      "Il est interdit d’utiliser l’application à des fins illégales, commerciales (non autorisées), ou nuisibles pour autrui.",
                    ),
                    SizedBox(height: 16),

                    Text(
                      "4. Contenu des Annonces",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Les annonces doivent respecter les lois en vigueur. "
                      "L’utilisateur reste responsable du contenu qu’il publie. "
                      "L’application se réserve le droit de modérer, modifier ou supprimer tout contenu jugé inapproprié.",
                    ),
                    SizedBox(height: 16),

                    Text(
                      "5. Responsabilité et Paiement",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Les paiements entre utilisateurs peuvent se faire en main propre ou via des moyens sécurisés proposés par l’application. "
                      "L’application n’est pas responsable des différends entre utilisateurs liés aux paiements ou à la qualité des services.",
                    ),
                    SizedBox(height: 16),

                    Text(
                      "6. Données Personnelles",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Vos données sont traitées dans le respect de la législation applicable sur la protection des données. "
                      "Certaines informations peuvent être partagées dans le cadre de l’utilisation de l’application.",
                    ),
                    SizedBox(height: 16),

                    Text(
                      "7. Sécurité et Fiabilité",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Nous nous efforçons d’assurer la sécurité et la disponibilité de l’application, "
                      "mais nous ne garantissons pas l’absence de bugs, d’interruptions ou d’erreurs.",
                    ),
                    SizedBox(height: 16),

                    Text(
                      "8. Résiliation et Suppression",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Vous pouvez supprimer votre compte à tout moment. "
                      "En cas de non-respect des conditions, l’application peut suspendre ou supprimer un compte sans préavis.",
                    ),
                    SizedBox(height: 16),

                    Text(
                      "9. Modifications des Conditions",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Les présentes conditions peuvent être mises à jour à tout moment. "
                      "En continuant d’utiliser l’application, vous acceptez les nouvelles conditions.",
                    ),
                    SizedBox(height: 16),

                    Text(
                      "10. Contact",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Pour toute question ou réclamation, contactez-nous à l’adresse suivante : contact@bricorasy.com",
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
