// lib/data/price_catalog_data.dart
import 'package:bricorasy/models/price_catalog_item.dart'; // Import the model

final List<PriceCategory> priceCatalogData = [
  PriceCategory(name: 'Plomberie', items: [
    PriceCatalogItem(service: 'Installation chauffe-eau', priceRange: '2 000 DA - 4 000 DA'),
    PriceCatalogItem(service: 'Installation WC', priceRange: '6 000 DA - 8 000 DA'),
    PriceCatalogItem(service: 'Réparation fuite', priceRange: '2 000 DA - 4 000 DA'),
  ]),
  PriceCategory(name: 'Électricité', items: [
    PriceCatalogItem(service: 'Dépannage électrique', priceRange: '2 000 DA - 5 000 DA'),
    PriceCatalogItem(service: 'Pose prise électrique', priceRange: '500 DA - 1 500 DA'),
  ]),
  PriceCategory(name: 'Peinture', items: [
    PriceCatalogItem(service: 'Peinture murale (m²)', priceRange: '300 DA - 500 DA'),
    PriceCatalogItem(service: 'Peinture plafond (m²)', priceRange: '400 DA - 600 DA'),
  ]),
  PriceCategory(name: 'Menuiserie', items: [
    PriceCatalogItem(service: 'Fabrication étagère', priceRange: '5 000 DA - 10 000 DA'),
    PriceCatalogItem(service: 'Réparation porte bois', priceRange: '3 000 DA - 6 000 DA'),
  ]),
  PriceCategory(name: 'Climatisation', items: [
    PriceCatalogItem(service: 'Installation split', priceRange: '10 000 DA - 20 000 DA'),
    PriceCatalogItem(service: 'Recharge gaz', priceRange: '4 000 DA - 8 000 DA'),
  ]),
  PriceCategory(name: 'Maçonnerie', items: [
    PriceCatalogItem(service: 'Réparation mur fissuré', priceRange: '2 500 DA - 5 000 DA'),
    PriceCatalogItem(service: 'Coulage dalle béton (m²)', priceRange: '1 500 DA - 3 000 DA'),
  ]),
  PriceCategory(name: 'Jardinage', items: [
    PriceCatalogItem(service: 'Taille haie (heure)', priceRange: '1 000 DA - 2 000 DA'),
    PriceCatalogItem(service: 'Aménagement jardin (m²)', priceRange: '2 000 DA - 5 000 DA'),
  ]),
  PriceCategory(name: 'Serrurerie', items: [
    PriceCatalogItem(service: 'Changement serrure', priceRange: '1 500 DA - 3 000 DA'),
    PriceCatalogItem(service: 'Ouverture porte claquée', priceRange: '4 000 DA - 8 000 DA'),
  ]),
  PriceCategory(name: 'Carrelage', items: [
    PriceCatalogItem(service: 'Pose carrelage (m²)', priceRange: '1 200 DA - 2 500 DA'),
    PriceCatalogItem(service: 'Jointoiement (m²)', priceRange: '500 DA - 1 000 DA'),
  ]),
  PriceCategory(name: 'Vitrerie', items: [
    PriceCatalogItem(service: 'Remplacement vitre brisée', priceRange: '2 000 DA - 5 000 DA'),
    PriceCatalogItem(service: 'Installation miroir', priceRange: '3 000 DA - 6 000 DA'),
  ]),
  PriceCategory(name: 'Déménagement', items: [
    PriceCatalogItem(service: 'Camionnette (heure)', priceRange: '1 500 DA - 3 000 DA'),
    PriceCatalogItem(service: 'Assemblage meuble', priceRange: '2 000 DA - 4 000 DA'),
  ]),
  PriceCategory(name: 'Métallerie', items: [
    PriceCatalogItem(service: 'Soudure (petit projet)', priceRange: '3 000 DA - 6 000 DA'),
    PriceCatalogItem(service: 'Fabrication grille', priceRange: '10 000 DA - 20 000 DA'),
  ]),
  PriceCategory(name: 'Clôtures', items: [
    PriceCatalogItem(service: 'Pose clôture métallique (m)', priceRange: '2 000 DA - 4 000 DA'),
    PriceCatalogItem(service: 'Clôture béton (m)', priceRange: '5 000 DA - 8 000 DA'),
  ]),
  PriceCategory(name: 'Isolation', items: [
    PriceCatalogItem(service: 'Isolation toiture (m²)', priceRange: '1 500 DA - 3 000 DA'),
    PriceCatalogItem(service: 'Laine de verre (m²)', priceRange: '800 DA - 1 500 DA'),
  ]),
  PriceCategory(name: 'Toiture', items: [
    PriceCatalogItem(service: 'Réparation tuile', priceRange: '1 000 DA - 2 500 DA'),
    PriceCatalogItem(service: 'Étanchéité toit plat', priceRange: '3 000 DA - 6 000 DA'),
  ]),
  PriceCategory(name: 'Piscine', items: [
    PriceCatalogItem(service: 'Nettoyage piscine', priceRange: '8 000 DA - 15 000 DA'),
    PriceCatalogItem(service: 'Réparation pompe', priceRange: '5 000 DA - 10 000 DA'),
  ]),
  PriceCategory(name: 'Élagage', items: [
    PriceCatalogItem(service: 'Abattage arbre (unité)', priceRange: '10 000 DA - 25 000 DA'),
    PriceCatalogItem(service: 'Taille palmier', priceRange: '3 000 DA - 6 000 DA'),
  ]),
  PriceCategory(name: 'Chauffage', items: [
    PriceCatalogItem(service: 'Pose radiateur', priceRange: '4 000 DA - 8 000 DA'),
    PriceCatalogItem(service: 'Installation chaudière', priceRange: '15 000 DA - 25 000 DA'),
  ]),
  PriceCategory(name: 'Salle de bain', items: [
    PriceCatalogItem(service: 'Rénovation complète', priceRange: '100 000 DA - 300 000 DA'),
    PriceCatalogItem(service: 'Pose baignoire', priceRange: '8 000 DA - 15 000 DA'),
  ]),
  PriceCategory(name: 'Portes/Fenêtres', items: [
    PriceCatalogItem(service: 'Installation porte blindée', priceRange: '20 000 DA - 40 000 DA'),
    PriceCatalogItem(service: 'Remplacement fenêtre', priceRange: '10 000 DA - 20 000 DA'),
  ]),
  PriceCategory(name: 'Décoration', items: [
    PriceCatalogItem(service: 'Pose papier peint (m²)', priceRange: '800 DA - 1 500 DA'),
    PriceCatalogItem(service: 'Installation étagère murale', priceRange: '2 000 DA - 4 000 DA'),
  ]),
  PriceCategory(name: 'Pressing', items: [
    PriceCatalogItem(service: 'Nettoyage tapis (m²)', priceRange: '400 DA - 800 DA'),
    PriceCatalogItem(service: 'Lavage canapé', priceRange: '6 000 DA - 12 000 DA'),
  ]),
  PriceCategory(name: 'Design Web', items: [
    PriceCatalogItem(service: 'Site vitrine simple', priceRange: '30 000 DA - 80 000 DA'),
    PriceCatalogItem(service: 'Site e-commerce', priceRange: '150 000 DA - 800 000 DA'),
  ]),
  PriceCategory(name: 'Nettoyage', items: [
    PriceCatalogItem(service: 'Nettoyage standard (par m²)', priceRange: '100 DA - 200 DA'),
    PriceCatalogItem(service: 'Nettoyage après travaux', priceRange: '300 DA - 500 DA'),
  ]),
  // ... Add all other categories and items
];