// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Welcome to our world!`
  String get OnBoarding1title {
    return Intl.message(
      'Welcome to our world!',
      name: 'OnBoarding1title',
      desc: '',
      args: [],
    );
  }

  /// `Start your journey with us and discover a smart and easy shopping experience at your fingertips.`
  String get OnBoarding1description {
    return Intl.message(
      'Start your journey with us and discover a smart and easy shopping experience at your fingertips.',
      name: 'OnBoarding1description',
      desc: '',
      args: [],
    );
  }

  /// `Everything you need in one place`
  String get OnBoarding2title {
    return Intl.message(
      'Everything you need in one place',
      name: 'OnBoarding2title',
      desc: '',
      args: [],
    );
  }

  /// `From your favorite products to the latest offers — everything is within your reach in one step.`
  String get OnBoarding2description {
    return Intl.message(
      'From your favorite products to the latest offers — everything is within your reach in one step.',
      name: 'OnBoarding2description',
      desc: '',
      args: [],
    );
  }

  /// `Shop smart and confidently`
  String get OnBoarding3title {
    return Intl.message(
      'Shop smart and confidently',
      name: 'OnBoarding3title',
      desc: '',
      args: [],
    );
  }

  /// `We offer you a shopping experience that combines speed, comfort, and the quality you deserve.`
  String get OnBoarding3description {
    return Intl.message(
      'We offer you a shopping experience that combines speed, comfort, and the quality you deserve.',
      name: 'OnBoarding3description',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get Start {
    return Intl.message('Start', name: 'Start', desc: '', args: []);
  }

  /// `Next`
  String get Next {
    return Intl.message('Next', name: 'Next', desc: '', args: []);
  }

  /// `Skip`
  String get Skip {
    return Intl.message('Skip', name: 'Skip', desc: '', args: []);
  }

  /// `Not a member?`
  String get NotAMember {
    return Intl.message(
      'Not a member?',
      name: 'NotAMember',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get SignUp {
    return Intl.message('Sign Up', name: 'SignUp', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Verify Phone Number`
  String get VerifyPhoneNumber {
    return Intl.message(
      'Verify Phone Number',
      name: 'VerifyPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter the verification code sent to 01017900067`
  String get SubVerifyPhoneNumber {
    return Intl.message(
      'Enter the verification code sent to 01017900067',
      name: 'SubVerifyPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get Verify {
    return Intl.message('Verify', name: 'Verify', desc: '', args: []);
  }

  /// `Resend code after 00:59`
  String get ResendCode {
    return Intl.message(
      'Resend code after 00:59',
      name: 'ResendCode',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get FullName {
    return Intl.message('Full Name', name: 'FullName', desc: '', args: []);
  }

  /// `Already have an account?`
  String get AlreadyHaveAnAccount {
    return Intl.message(
      'Already have an account?',
      name: 'AlreadyHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get PhoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'PhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get location {
    return Intl.message('Address', name: 'location', desc: '', args: []);
  }

  /// `Country`
  String get Country {
    return Intl.message('Country', name: 'Country', desc: '', args: []);
  }

  /// `City`
  String get City {
    return Intl.message('City', name: 'City', desc: '', args: []);
  }

  /// `Choose Country Code`
  String get ChooseCountryCode {
    return Intl.message(
      'Choose Country Code',
      name: 'ChooseCountryCode',
      desc: '',
      args: [],
    );
  }

  /// `Choose the account type that suits your needs.`
  String get ChooseAccountType {
    return Intl.message(
      'Choose the account type that suits your needs.',
      name: 'ChooseAccountType',
      desc: '',
      args: [],
    );
  }

  /// `Seller`
  String get seller {
    return Intl.message('Seller', name: 'seller', desc: '', args: []);
  }

  /// `Buyer`
  String get buyer {
    return Intl.message('Buyer', name: 'buyer', desc: '', args: []);
  }

  /// `More`
  String get more {
    return Intl.message('More', name: 'more', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Hello Mahmoud`
  String get HelloMahmoud {
    return Intl.message(
      'Hello Mahmoud',
      name: 'HelloMahmoud',
      desc: '',
      args: [],
    );
  }

  /// `My Orders`
  String get MyShipments {
    return Intl.message('My Orders', name: 'MyShipments', desc: '', args: []);
  }

  /// `My Profile`
  String get profile {
    return Intl.message('My Profile', name: 'profile', desc: '', args: []);
  }

  /// `Home`
  String get Home {
    return Intl.message('Home', name: 'Home', desc: '', args: []);
  }

  /// `Cart`
  String get Cart {
    return Intl.message('Cart', name: 'Cart', desc: '', args: []);
  }

  /// `Add to Cart`
  String get AddtoCart {
    return Intl.message('Add to Cart', name: 'AddtoCart', desc: '', args: []);
  }

  /// `Product`
  String get Product {
    return Intl.message('Product', name: 'Product', desc: '', args: []);
  }

  /// `Notifications`
  String get notificationsTitle {
    return Intl.message(
      'Notifications',
      name: 'notificationsTitle',
      desc: '',
      args: [],
    );
  }

  /// `You have no notifications yet`
  String get noNotifications {
    return Intl.message(
      'You have no notifications yet',
      name: 'noNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Enjoy an exclusive 25% discount on your first order`
  String get exclusiveOffer {
    return Intl.message(
      'Enjoy an exclusive 25% discount on your first order',
      name: 'exclusiveOffer',
      desc: '',
      args: [],
    );
  }

  /// `Browse Products`
  String get browseProducts {
    return Intl.message(
      'Browse Products',
      name: 'browseProducts',
      desc: '',
      args: [],
    );
  }

  /// `SYP`
  String get SYP {
    return Intl.message('SYP', name: 'SYP', desc: '', args: []);
  }

  /// `Products`
  String get Products {
    return Intl.message('Products', name: 'Products', desc: '', args: []);
  }

  /// `Subtotal`
  String get Subtotal {
    return Intl.message('Subtotal', name: 'Subtotal', desc: '', args: []);
  }

  /// `Total`
  String get Total {
    return Intl.message('Total', name: 'Total', desc: '', args: []);
  }

  /// `Checkout`
  String get Checkout {
    return Intl.message('Checkout', name: 'Checkout', desc: '', args: []);
  }

  /// `Your cart is empty!`
  String get emptyCart {
    return Intl.message(
      'Your cart is empty!',
      name: 'emptyCart',
      desc: '',
      args: [],
    );
  }

  /// `Browse products and shop now`
  String get browseAndShopNow {
    return Intl.message(
      'Browse products and shop now',
      name: 'browseAndShopNow',
      desc: '',
      args: [],
    );
  }

  /// `Payment Method`
  String get paymentMethod {
    return Intl.message(
      'Payment Method',
      name: 'paymentMethod',
      desc: '',
      args: [],
    );
  }

  /// `Cash`
  String get cash {
    return Intl.message('Cash', name: 'cash', desc: '', args: []);
  }

  /// `Visa`
  String get visa {
    return Intl.message('Visa', name: 'visa', desc: '', args: []);
  }

  /// `Discount`
  String get discount {
    return Intl.message('Discount', name: 'discount', desc: '', args: []);
  }

  /// `Complete Purchase`
  String get completePurchase {
    return Intl.message(
      'Complete Purchase',
      name: 'completePurchase',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Favorite Products`
  String get favoriteProducts {
    return Intl.message(
      'Favorite Products',
      name: 'favoriteProducts',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Favorite`
  String get favorite {
    return Intl.message('Favorite', name: 'favorite', desc: '', args: []);
  }

  /// `No favorite products`
  String get noFavorites {
    return Intl.message(
      'No favorite products',
      name: 'noFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Street`
  String get street {
    return Intl.message('Street', name: 'street', desc: '', args: []);
  }

  /// `Description`
  String get description {
    return Intl.message('Description', name: 'description', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Search not found`
  String get searchNotFound {
    return Intl.message(
      'Search not found',
      name: 'searchNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `New Notification`
  String get newNotification {
    return Intl.message(
      'New Notification',
      name: 'newNotification',
      desc: '',
      args: [],
    );
  }

  /// `About Us`
  String get AboutUs {
    return Intl.message('About Us', name: 'AboutUs', desc: '', args: []);
  }

  /// `Privacy Policy`
  String get PrivacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'PrivacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Invite Friends`
  String get InviteFriends {
    return Intl.message(
      'Invite Friends',
      name: 'InviteFriends',
      desc: '',
      args: [],
    );
  }

  /// `App Support`
  String get AppSupport {
    return Intl.message('App Support', name: 'AppSupport', desc: '', args: []);
  }

  /// `Terms and Conditions`
  String get TermsandConditions {
    return Intl.message(
      'Terms and Conditions',
      name: 'TermsandConditions',
      desc: '',
      args: [],
    );
  }

  /// `No Results to Show`
  String get NoResultstoShow {
    return Intl.message(
      'No Results to Show',
      name: 'NoResultstoShow',
      desc: '',
      args: [],
    );
  }

  /// `My Shipments`
  String get myShipments {
    return Intl.message(
      'My Shipments',
      name: 'myShipments',
      desc: '',
      args: [],
    );
  }

  /// `Current`
  String get currentTab {
    return Intl.message('Current', name: 'currentTab', desc: '', args: []);
  }

  /// `Completed`
  String get completedTab {
    return Intl.message('Completed', name: 'completedTab', desc: '', args: []);
  }

  /// `Cancelled`
  String get cancelledTab {
    return Intl.message('Cancelled', name: 'cancelledTab', desc: '', args: []);
  }

  /// `Fashion`
  String get fashionCategory {
    return Intl.message('Fashion', name: 'fashionCategory', desc: '', args: []);
  }

  /// `Electronics`
  String get electronicsCategory {
    return Intl.message(
      'Electronics',
      name: 'electronicsCategory',
      desc: '',
      args: [],
    );
  }

  /// `Kitchen`
  String get kitchenCategory {
    return Intl.message('Kitchen', name: 'kitchenCategory', desc: '', args: []);
  }

  /// `Accessories`
  String get accessoriesCategory {
    return Intl.message(
      'Accessories',
      name: 'accessoriesCategory',
      desc: '',
      args: [],
    );
  }

  /// `Out of Stock`
  String get outOfStock {
    return Intl.message('Out of Stock', name: 'outOfStock', desc: '', args: []);
  }

  /// `Shipping Not Available to This Location`
  String get shippingNotAvailable {
    return Intl.message(
      'Shipping Not Available to This Location',
      name: 'shippingNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Cancellation Reason Not Specified`
  String get cancellationReasonNotSpecified {
    return Intl.message(
      'Cancellation Reason Not Specified',
      name: 'cancellationReasonNotSpecified',
      desc: '',
      args: [],
    );
  }

  /// `Received`
  String get receivedStatus {
    return Intl.message('Received', name: 'receivedStatus', desc: '', args: []);
  }

  /// `Cancelled`
  String get cancelledStatus {
    return Intl.message(
      'Cancelled',
      name: 'cancelledStatus',
      desc: '',
      args: [],
    );
  }

  /// `Order Details`
  String get orderDetails {
    return Intl.message(
      'Order Details',
      name: 'orderDetails',
      desc: '',
      args: [],
    );
  }

  /// `Product Details`
  String get productDetails {
    return Intl.message(
      'Product Details',
      name: 'productDetails',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get descriptionLabel {
    return Intl.message(
      'Description',
      name: 'descriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get quantityLabel {
    return Intl.message('Quantity', name: 'quantityLabel', desc: '', args: []);
  }

  /// `Price`
  String get priceLabel {
    return Intl.message('Price', name: 'priceLabel', desc: '', args: []);
  }

  /// `Shipping Cost`
  String get shippingCostLabel {
    return Intl.message(
      'Shipping Cost',
      name: 'shippingCostLabel',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get totalLabel {
    return Intl.message('Total', name: 'totalLabel', desc: '', args: []);
  }

  /// `Order Status`
  String get orderStatus {
    return Intl.message(
      'Order Status',
      name: 'orderStatus',
      desc: '',
      args: [],
    );
  }

  /// `Order Confirmed`
  String get orderConfirmed {
    return Intl.message(
      'Order Confirmed',
      name: 'orderConfirmed',
      desc: '',
      args: [],
    );
  }

  /// `Shipped`
  String get shippedStatus {
    return Intl.message('Shipped', name: 'shippedStatus', desc: '', args: []);
  }

  /// `January`
  String get january {
    return Intl.message('January', name: 'january', desc: '', args: []);
  }

  /// `February`
  String get february {
    return Intl.message('February', name: 'february', desc: '', args: []);
  }

  /// `March`
  String get march {
    return Intl.message('March', name: 'march', desc: '', args: []);
  }

  /// `April`
  String get april {
    return Intl.message('April', name: 'april', desc: '', args: []);
  }

  /// `May`
  String get may {
    return Intl.message('May', name: 'may', desc: '', args: []);
  }

  /// `June`
  String get june {
    return Intl.message('June', name: 'june', desc: '', args: []);
  }

  /// `July`
  String get july {
    return Intl.message('July', name: 'july', desc: '', args: []);
  }

  /// `August`
  String get august {
    return Intl.message('August', name: 'august', desc: '', args: []);
  }

  /// `September`
  String get september {
    return Intl.message('September', name: 'september', desc: '', args: []);
  }

  /// `October`
  String get october {
    return Intl.message('October', name: 'october', desc: '', args: []);
  }

  /// `November`
  String get november {
    return Intl.message('November', name: 'november', desc: '', args: []);
  }

  /// `December`
  String get december {
    return Intl.message('December', name: 'december', desc: '', args: []);
  }

  /// `App Support`
  String get appSupport {
    return Intl.message('App Support', name: 'appSupport', desc: '', args: []);
  }

  /// `Choose the type of support you wish to provide:`
  String get chooseSupportType {
    return Intl.message(
      'Choose the type of support you wish to provide:',
      name: 'chooseSupportType',
      desc: '',
      args: [],
    );
  }

  /// `Financial Support`
  String get financialSupport {
    return Intl.message(
      'Financial Support',
      name: 'financialSupport',
      desc: '',
      args: [],
    );
  }

  /// `In-Kind Support`
  String get inKindSupport {
    return Intl.message(
      'In-Kind Support',
      name: 'inKindSupport',
      desc: '',
      args: [],
    );
  }

  /// `Financial Support Form`
  String get financialSupportForm {
    return Intl.message(
      'Financial Support Form',
      name: 'financialSupportForm',
      desc: '',
      args: [],
    );
  }

  /// `Supported Entity`
  String get charityName {
    return Intl.message(
      'Supported Entity',
      name: 'charityName',
      desc: '',
      args: [],
    );
  }

  /// `Enter the supported entity name`
  String get enterCharityName {
    return Intl.message(
      'Enter the supported entity name',
      name: 'enterCharityName',
      desc: '',
      args: [],
    );
  }

  /// `Donation Amount`
  String get donationAmount {
    return Intl.message(
      'Donation Amount',
      name: 'donationAmount',
      desc: '',
      args: [],
    );
  }

  /// `Enter the donation amount`
  String get enterDonationAmount {
    return Intl.message(
      'Enter the donation amount',
      name: 'enterDonationAmount',
      desc: '',
      args: [],
    );
  }

  /// `Submit Request`
  String get submitRequest {
    return Intl.message(
      'Submit Request',
      name: 'submitRequest',
      desc: '',
      args: [],
    );
  }

  /// `Your request will be reviewed, and you will be notified upon approval`
  String get requestReviewNotification {
    return Intl.message(
      'Your request will be reviewed, and you will be notified upon approval',
      name: 'requestReviewNotification',
      desc: '',
      args: [],
    );
  }

  /// `In-Kind Support Form`
  String get inKindSupportForm {
    return Intl.message(
      'In-Kind Support Form',
      name: 'inKindSupportForm',
      desc: '',
      args: [],
    );
  }

  /// `Type of In-Kind Support`
  String get inKindSupportType {
    return Intl.message(
      'Type of In-Kind Support',
      name: 'inKindSupportType',
      desc: '',
      args: [],
    );
  }

  /// `Example: Food, Clothing, Household Items`
  String get inKindSupportExample {
    return Intl.message(
      'Example: Food, Clothing, Household Items',
      name: 'inKindSupportExample',
      desc: '',
      args: [],
    );
  }

  /// `Example: 10 kg rice, 5 winter clothes`
  String get inKindDescriptionExample {
    return Intl.message(
      'Example: 10 kg rice, 5 winter clothes',
      name: 'inKindDescriptionExample',
      desc: '',
      args: [],
    );
  }

  /// `Your request has been sent, a representative will contact you after approval.`
  String get requestSentNotification {
    return Intl.message(
      'Your request has been sent, a representative will contact you after approval.',
      name: 'requestSentNotification',
      desc: '',
      args: [],
    );
  }

  /// `Share your referral code with your friends!`
  String get shareReferralCode {
    return Intl.message(
      'Share your referral code with your friends!',
      name: 'shareReferralCode',
      desc: '',
      args: [],
    );
  }

  /// `Each person who uses your code to sign up gives you points or financial rewards after a specified number of referrals.`
  String get referralDescription {
    return Intl.message(
      'Each person who uses your code to sign up gives you points or financial rewards after a specified number of referrals.',
      name: 'referralDescription',
      desc: '',
      args: [],
    );
  }

  /// `Code copied successfully!`
  String get codeCopiedSuccess {
    return Intl.message(
      'Code copied successfully!',
      name: 'codeCopiedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Your Referral Users`
  String get yourReferralUsers {
    return Intl.message(
      'Your Referral Users',
      name: 'yourReferralUsers',
      desc: '',
      args: [],
    );
  }

  /// `Withdraw Earnings`
  String get withdrawEarnings {
    return Intl.message(
      'Withdraw Earnings',
      name: 'withdrawEarnings',
      desc: '',
      args: [],
    );
  }

  /// `Withdrawn`
  String get withdrawnAmount {
    return Intl.message(
      'Withdrawn',
      name: 'withdrawnAmount',
      desc: '',
      args: [],
    );
  }

  /// `Subtotal`
  String get subtotal {
    return Intl.message('Subtotal', name: 'subtotal', desc: '', args: []);
  }

  /// `Shipping Cost`
  String get shippingCost {
    return Intl.message(
      'Shipping Cost',
      name: 'shippingCost',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message('Total', name: 'total', desc: '', args: []);
  }

  /// `Checkout`
  String get checkout {
    return Intl.message('Checkout', name: 'checkout', desc: '', args: []);
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `No description`
  String get noDescription {
    return Intl.message(
      'No description',
      name: 'noDescription',
      desc: '',
      args: [],
    );
  }

  /// `Add to Cart`
  String get addToCart {
    return Intl.message('Add to Cart', name: 'addToCart', desc: '', args: []);
  }

  /// `Item removed from cart`
  String get itemRemoved {
    return Intl.message(
      'Item removed from cart',
      name: 'itemRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Added to Cart`
  String get addedToCart {
    return Intl.message(
      'Added to Cart',
      name: 'addedToCart',
      desc: '',
      args: [],
    );
  }

  /// `Card Number`
  String get cardNumber {
    return Intl.message('Card Number', name: 'cardNumber', desc: '', args: []);
  }

  /// `Expiry Date`
  String get expiryDate {
    return Intl.message('Expiry Date', name: 'expiryDate', desc: '', args: []);
  }

  /// `CVV`
  String get cvv {
    return Intl.message('CVV', name: 'cvv', desc: '', args: []);
  }

  /// `Card Holder Name`
  String get cardHolderName {
    return Intl.message(
      'Card Holder Name',
      name: 'cardHolderName',
      desc: '',
      args: [],
    );
  }

  /// `Payment Successful`
  String get paymentSuccess {
    return Intl.message(
      'Payment Successful',
      name: 'paymentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Order Successful`
  String get orderSuccess {
    return Intl.message(
      'Order Successful',
      name: 'orderSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Unspecified`
  String get categoryUnknown {
    return Intl.message(
      'Unspecified',
      name: 'categoryUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Suggestions`
  String get suggestions {
    return Intl.message('Suggestions', name: 'suggestions', desc: '', args: []);
  }

  /// `See More`
  String get seeMore {
    return Intl.message('See More', name: 'seeMore', desc: '', args: []);
  }

  /// `We wish you happy shopping!`
  String get happyShopping {
    return Intl.message(
      'We wish you happy shopping!',
      name: 'happyShopping',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `Lowest Price`
  String get lowestPrice {
    return Intl.message(
      'Lowest Price',
      name: 'lowestPrice',
      desc: '',
      args: [],
    );
  }

  /// `Highest Price`
  String get highestPrice {
    return Intl.message(
      'Highest Price',
      name: 'highestPrice',
      desc: '',
      args: [],
    );
  }

  /// `Tawqal Al-Najah Offers`
  String get tawqalOffers {
    return Intl.message(
      'Tawqal Al-Najah Offers',
      name: 'tawqalOffers',
      desc: '',
      args: [],
    );
  }

  /// `Filter Products`
  String get filterProducts {
    return Intl.message(
      'Filter Products',
      name: 'filterProducts',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message('Category', name: 'category', desc: '', args: []);
  }

  /// `Select Category`
  String get selectCategory {
    return Intl.message(
      'Select Category',
      name: 'selectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Country`
  String get country {
    return Intl.message('Country', name: 'country', desc: '', args: []);
  }

  /// `Select Country`
  String get selectCountry {
    return Intl.message(
      'Select Country',
      name: 'selectCountry',
      desc: '',
      args: [],
    );
  }

  /// `Price Range`
  String get priceRange {
    return Intl.message('Price Range', name: 'priceRange', desc: '', args: []);
  }

  /// `Apply Filters`
  String get applyFilters {
    return Intl.message(
      'Apply Filters',
      name: 'applyFilters',
      desc: '',
      args: [],
    );
  }

  /// `Stores`
  String get stores {
    return Intl.message('Stores', name: 'stores', desc: '', args: []);
  }

  /// `Categories`
  String get categories {
    return Intl.message('Categories', name: 'categories', desc: '', args: []);
  }

  /// `Electronics`
  String get electronics {
    return Intl.message('Electronics', name: 'electronics', desc: '', args: []);
  }

  /// `Fashion`
  String get fashion {
    return Intl.message('Fashion', name: 'fashion', desc: '', args: []);
  }

  /// `Furniture`
  String get furniture {
    return Intl.message('Furniture', name: 'furniture', desc: '', args: []);
  }

  /// `Toys`
  String get toys {
    return Intl.message('Toys', name: 'toys', desc: '', args: []);
  }

  /// `Kitchen`
  String get kitchen {
    return Intl.message('Kitchen', name: 'kitchen', desc: '', args: []);
  }

  /// `Health`
  String get health {
    return Intl.message('Health', name: 'health', desc: '', args: []);
  }

  /// `Filter Merchants`
  String get filterMerchants {
    return Intl.message(
      'Filter Merchants',
      name: 'filterMerchants',
      desc: '',
      args: [],
    );
  }

  /// `Clothes`
  String get clothes {
    return Intl.message('Clothes', name: 'clothes', desc: '', args: []);
  }

  /// `Food`
  String get food {
    return Intl.message('Food', name: 'food', desc: '', args: []);
  }

  /// `Merchants`
  String get merchants {
    return Intl.message('Merchants', name: 'merchants', desc: '', args: []);
  }

  /// `Store`
  String get store {
    return Intl.message('Store', name: 'store', desc: '', args: []);
  }

  /// `Filter`
  String get filter {
    return Intl.message('Filter', name: 'filter', desc: '', args: []);
  }

  /// `Minimum Price`
  String get minimumPrice {
    return Intl.message(
      'Minimum Price',
      name: 'minimumPrice',
      desc: '',
      args: [],
    );
  }

  /// `Maximum Price`
  String get maximumPrice {
    return Intl.message(
      'Maximum Price',
      name: 'maximumPrice',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get city {
    return Intl.message('City', name: 'city', desc: '', args: []);
  }

  /// `Apply`
  String get apply {
    return Intl.message('Apply', name: 'apply', desc: '', args: []);
  }

  /// `An error occurred while opening the link`
  String get errorOpeningLink {
    return Intl.message(
      'An error occurred while opening the link',
      name: 'errorOpeningLink',
      desc: '',
      args: [],
    );
  }

  /// `Your Product Rating`
  String get yourProductRating {
    return Intl.message(
      'Your Product Rating',
      name: 'yourProductRating',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
