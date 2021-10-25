import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

class MyLocalizations {
  MyLocalizations(this.locale);

  final Locale locale;

  static MyLocalizations? of(BuildContext context) {
    return Localizations.of<MyLocalizations>(context, MyLocalizations);
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'alcohol': 'Alcohol',
      'barcode': 'Barcode',
      'brand_created': 'Brand created',
      'brand_deleted': 'Brand deleted',
      'brand': 'Brand',
      'cancel': 'Cancel',
      'categories': 'Categories',
      'category_created': 'Category created',
      'category_deleted': 'Category deleted',
      'category': 'Category',
      'create_item': 'New',
      'description': 'Description',
      'edit_brand': 'Edit brand',
      'edit_category': 'Edit category',
      'edit_item': 'Edit item',
      'get_latest_release': 'Get latest release from GitHub',
      'hostname': 'Hostname',
      'item_created': 'Beverage created',
      'item_deleted': 'Beverage deleted',
      'name': 'Name',
      'new_brand': 'New brand',
      'new_category': 'New category',
      'new_item': 'New beverage',
      'no_brands': 'No brands',
      'no_categories': 'No categories',
      'please_enter_some_text': 'Please enter some text',
      'rating': 'Rating',
      'search': 'Search',
      'settings': 'Settings',
      'submit': 'Submit',
      'title': 'Title',
      'token': 'Token',
      'try_new_token': 'Please try a new token'
    },
    'fr': {
      'alcohol': 'Alcool',
      'barcode': 'Code barre',
      'brand_created': 'Marque créée',
      'brand_deleted': 'Marque supprimée',
      'brand': 'Marque',
      'cancel': 'Annuler',
      'categories': 'Catégories',
      'category_created': 'Catégorie créée',
      'category_deleted': 'Catégorie supprimée',
      'category': 'Catégorie',
      'create_item': 'Ajouter',
      'description': 'Description',
      'edit_brand': 'Éditer marque',
      'edit_category': 'Éditer catégorie',
      'edit_item': 'Éditer',
      'get_latest_release': 'Récupérer la dernière version sur GitHub',
      'hostname': 'Serveur',
      'item_created': 'Boisson créée',
      'item_deleted': 'Boisson supprimée',
      'name': 'Nom',
      'new_brand': 'Nouvelle marque',
      'new_category': 'Nouvelle catégorie',
      'new_item': 'Nouvelle boisson',
      'no_brands': 'Aucune marque',
      'no_categories': 'Aucune catégorie',
      'please_enter_some_text': 'Veuillez entrer du texte',
      'rating': 'Note',
      'search': 'Rechercher',
      'settings': 'Paramètres',
      'submit': 'Valider',
      'title': 'Titre',
      'token': 'Jeton de sécurité',
      'try_new_token': 'Veuillez mettre à jour votre jeton de sécurité'
    },
  };

  String tr(String token) {
    return _localizedValues[locale.languageCode]![token] ?? token;
  }

  static String localizedValue(String locale, String token) {
    final lcl = ['en', 'fr'].contains(locale) ? locale : 'en';
    return _localizedValues[lcl]![token] ?? token;
  }
}

class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
  const MyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<MyLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async 'load' operation
    // isn't needed to produce an instance of MyLocalizations.
    return SynchronousFuture<MyLocalizations>(MyLocalizations(locale));
  }

  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;
}
