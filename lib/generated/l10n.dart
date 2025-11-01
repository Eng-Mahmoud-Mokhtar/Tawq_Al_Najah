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

  /// `Each person who registers using your code brings you closer to receiving a special reward after a certain number of invites.`
  String get referralDescription {
    return Intl.message(
      'Each person who registers using your code brings you closer to receiving a special reward after a certain number of invites.',
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

  /// `Removed successfully`
  String get itemRemoved {
    return Intl.message(
      'Removed successfully',
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

  /// `Rewards`
  String get Rewards {
    return Intl.message('Rewards', name: 'Rewards', desc: '', args: []);
  }

  /// `My Store`
  String get MyStore {
    return Intl.message('My Store', name: 'MyStore', desc: '', args: []);
  }

  /// `My Orders`
  String get MyOrders {
    return Intl.message('My Orders', name: 'MyOrders', desc: '', args: []);
  }

  /// `Activity Type`
  String get activityType {
    return Intl.message(
      'Activity Type',
      name: 'activityType',
      desc: '',
      args: [],
    );
  }

  /// `Enter activity type`
  String get enterActivityType {
    return Intl.message(
      'Enter activity type',
      name: 'enterActivityType',
      desc: '',
      args: [],
    );
  }

  /// `Number of Branches`
  String get branchesCount {
    return Intl.message(
      'Number of Branches',
      name: 'branchesCount',
      desc: '',
      args: [],
    );
  }

  /// `Enter number of branches`
  String get enterBranchesCount {
    return Intl.message(
      'Enter number of branches',
      name: 'enterBranchesCount',
      desc: '',
      args: [],
    );
  }

  /// `Site Area`
  String get siteArea {
    return Intl.message('Site Area', name: 'siteArea', desc: '', args: []);
  }

  /// `Enter area`
  String get enterArea {
    return Intl.message('Enter area', name: 'enterArea', desc: '', args: []);
  }

  /// `m²`
  String get meters {
    return Intl.message('m²', name: 'meters', desc: '', args: []);
  }

  /// `Contract Duration`
  String get contractDuration {
    return Intl.message(
      'Contract Duration',
      name: 'contractDuration',
      desc: '',
      args: [],
    );
  }

  /// `3 Months`
  String get threeMonths {
    return Intl.message('3 Months', name: 'threeMonths', desc: '', args: []);
  }

  /// `6 Months`
  String get sixMonths {
    return Intl.message('6 Months', name: 'sixMonths', desc: '', args: []);
  }

  /// `1 Year`
  String get oneYear {
    return Intl.message('1 Year', name: 'oneYear', desc: '', args: []);
  }

  /// `Other`
  String get other {
    return Intl.message('Other', name: 'other', desc: '', args: []);
  }

  /// `Custom Duration`
  String get customDuration {
    return Intl.message(
      'Custom Duration',
      name: 'customDuration',
      desc: '',
      args: [],
    );
  }

  /// `Enter your preferred duration`
  String get enterCustomDuration {
    return Intl.message(
      'Enter your preferred duration',
      name: 'enterCustomDuration',
      desc: '',
      args: [],
    );
  }

  /// `Upload commercial registration and documents`
  String get uploadDocs {
    return Intl.message(
      'Upload commercial registration and documents',
      name: 'uploadDocs',
      desc: '',
      args: [],
    );
  }

  /// `Add File`
  String get addFile {
    return Intl.message('Add File', name: 'addFile', desc: '', args: []);
  }

  /// `Social Media Links`
  String get socialLinks {
    return Intl.message(
      'Social Media Links',
      name: 'socialLinks',
      desc: '',
      args: [],
    );
  }

  /// `Enter social link`
  String get enterSocialLink {
    return Intl.message(
      'Enter social link',
      name: 'enterSocialLink',
      desc: '',
      args: [],
    );
  }

  /// `Invalid or unsupported platform`
  String get unsupportedPlatform {
    return Intl.message(
      'Invalid or unsupported platform',
      name: 'unsupportedPlatform',
      desc: '',
      args: [],
    );
  }

  /// `Shop / Seller Name`
  String get ShopSellerName {
    return Intl.message(
      'Shop / Seller Name',
      name: 'ShopSellerName',
      desc: '',
      args: [],
    );
  }

  /// `Account Info`
  String get AccountInfo {
    return Intl.message(
      'Account Info',
      name: 'AccountInfo',
      desc: '',
      args: [],
    );
  }

  /// `joined Since`
  String get joinedSince {
    return Intl.message(
      'joined Since',
      name: 'joinedSince',
      desc: '',
      args: [],
    );
  }

  /// `Contracting`
  String get contract_history {
    return Intl.message(
      'Contracting',
      name: 'contract_history',
      desc: '',
      args: [],
    );
  }

  /// `Ratings`
  String get ratings {
    return Intl.message('Ratings', name: 'ratings', desc: '', args: []);
  }

  /// `No contracts found`
  String get no_contracts_found {
    return Intl.message(
      'No contracts found',
      name: 'no_contracts_found',
      desc: '',
      args: [],
    );
  }

  /// `No ratings yet`
  String get no_ratings_yet {
    return Intl.message(
      'No ratings yet',
      name: 'no_ratings_yet',
      desc: '',
      args: [],
    );
  }

  /// `Branch Location`
  String get branch {
    return Intl.message('Branch Location', name: 'branch', desc: '', args: []);
  }

  /// `Enter branch location`
  String get enterBranchLocation {
    return Intl.message(
      'Enter branch location',
      name: 'enterBranchLocation',
      desc: '',
      args: [],
    );
  }

  /// `Total Area`
  String get totalArea {
    return Intl.message('Total Area', name: 'totalArea', desc: '', args: []);
  }

  /// `Enter total area`
  String get enterTotalArea {
    return Intl.message(
      'Enter total area',
      name: 'enterTotalArea',
      desc: '',
      args: [],
    );
  }

  /// `Monthly Price`
  String get monthlyPrice {
    return Intl.message(
      'Monthly Price',
      name: 'monthlyPrice',
      desc: '',
      args: [],
    );
  }

  /// `Your account has been created successfully`
  String get requestSent {
    return Intl.message(
      'Your account has been created successfully',
      name: 'requestSent',
      desc: '',
      args: [],
    );
  }

  /// `Your account is currently ready for use and is under review to ensure data accuracy. Any submission of false information will result in permanent account suspension.`
  String get requestReview {
    return Intl.message(
      'Your account is currently ready for use and is under review to ensure data accuracy. Any submission of false information will result in permanent account suspension.',
      name: 'requestReview',
      desc: '',
      args: [],
    );
  }

  /// `Back to Home Page`
  String get backHome {
    return Intl.message(
      'Back to Home Page',
      name: 'backHome',
      desc: '',
      args: [],
    );
  }

  /// `related Items`
  String get relatedItems {
    return Intl.message(
      'related Items',
      name: 'relatedItems',
      desc: '',
      args: [],
    );
  }

  /// `Contract Start Date:`
  String get start_date {
    return Intl.message(
      'Contract Start Date:',
      name: 'start_date',
      desc: '',
      args: [],
    );
  }

  /// `End Date:`
  String get end_date {
    return Intl.message('End Date:', name: 'end_date', desc: '', args: []);
  }

  /// `Renew Contract`
  String get renew_contract {
    return Intl.message(
      'Renew Contract',
      name: 'renew_contract',
      desc: '',
      args: [],
    );
  }

  /// `Renewal request sent successfully`
  String get renew_success {
    return Intl.message(
      'Renewal request sent successfully',
      name: 'renew_success',
      desc: '',
      args: [],
    );
  }

  /// `Overall Rating`
  String get overall_rating {
    return Intl.message(
      'Overall Rating',
      name: 'overall_rating',
      desc: '',
      args: [],
    );
  }

  /// `No Shipping`
  String get noShipping {
    return Intl.message('No Shipping', name: 'noShipping', desc: '', args: []);
  }

  /// `Local Shipping`
  String get localShipping {
    return Intl.message(
      'Local Shipping',
      name: 'localShipping',
      desc: '',
      args: [],
    );
  }

  /// `Local & International Shipping`
  String get bothShipping {
    return Intl.message(
      'Local & International Shipping',
      name: 'bothShipping',
      desc: '',
      args: [],
    );
  }

  /// `Installment not available`
  String get installmentNotAvailable {
    return Intl.message(
      'Installment not available',
      name: 'installmentNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `installment`
  String get installment {
    return Intl.message('installment', name: 'installment', desc: '', args: []);
  }

  /// `Cancel Order`
  String get cancelOrder {
    return Intl.message(
      'Cancel Order',
      name: 'cancelOrder',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel this order?\nA portion may be deducted based on app policy.`
  String get cancelOrderConfirmation {
    return Intl.message(
      'Are you sure you want to cancel this order?\nA portion may be deducted based on app policy.',
      name: 'cancelOrderConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message('Cancelled', name: 'cancelled', desc: '', args: []);
  }

  /// `Request Reward`
  String get requestReward {
    return Intl.message(
      'Request Reward',
      name: 'requestReward',
      desc: '',
      args: [],
    );
  }

  /// `Your reward request has been submitted successfully!`
  String get rewardRequestSent {
    return Intl.message(
      'Your reward request has been submitted successfully!',
      name: 'rewardRequestSent',
      desc: '',
      args: [],
    );
  }

  /// `Track your earned rewards from referrals and support`
  String get rewards_description {
    return Intl.message(
      'Track your earned rewards from referrals and support',
      name: 'rewards_description',
      desc: '',
      args: [],
    );
  }

  /// `Manage Orders`
  String get manageOrders {
    return Intl.message(
      'Manage Orders',
      name: 'manageOrders',
      desc: '',
      args: [],
    );
  }

  /// `New Orders`
  String get pendingTab {
    return Intl.message('New Orders', name: 'pendingTab', desc: '', args: []);
  }

  /// `Confirmed`
  String get confirmedTab {
    return Intl.message('Confirmed', name: 'confirmedTab', desc: '', args: []);
  }

  /// `Shipped`
  String get shippedTab {
    return Intl.message('Shipped', name: 'shippedTab', desc: '', args: []);
  }

  /// `Delivered`
  String get deliveredTab {
    return Intl.message('Delivered', name: 'deliveredTab', desc: '', args: []);
  }

  /// `No orders yet`
  String get noOrdersYet {
    return Intl.message(
      'No orders yet',
      name: 'noOrdersYet',
      desc: '',
      args: [],
    );
  }

  /// `Customer Information`
  String get customerInfo {
    return Intl.message(
      'Customer Information',
      name: 'customerInfo',
      desc: '',
      args: [],
    );
  }

  /// `Order Tracking`
  String get orderTracking {
    return Intl.message(
      'Order Tracking',
      name: 'orderTracking',
      desc: '',
      args: [],
    );
  }

  /// `Support contributions`
  String get support_count {
    return Intl.message(
      'Support contributions',
      name: 'support_count',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get otherCategory {
    return Intl.message('Other', name: 'otherCategory', desc: '', args: []);
  }

  /// `Number of Products`
  String get productsCount {
    return Intl.message(
      'Number of Products',
      name: 'productsCount',
      desc: '',
      args: [],
    );
  }

  /// `e.g., 500`
  String get enterProductsCount {
    return Intl.message(
      'e.g., 500',
      name: 'enterProductsCount',
      desc: '',
      args: [],
    );
  }

  /// `Monthly Visitors`
  String get monthlyVisitors {
    return Intl.message(
      'Monthly Visitors',
      name: 'monthlyVisitors',
      desc: '',
      args: [],
    );
  }

  /// `e.g., 10000`
  String get enterVisitorsCount {
    return Intl.message(
      'e.g., 10000',
      name: 'enterVisitorsCount',
      desc: '',
      args: [],
    );
  }

  /// `Please select a category`
  String get pleaseSelectCategory {
    return Intl.message(
      'Please select a category',
      name: 'pleaseSelectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Books`
  String get books {
    return Intl.message('Books', name: 'books', desc: '', args: []);
  }

  /// `Bank Account`
  String get bankAccount {
    return Intl.message(
      'Bank Account',
      name: 'bankAccount',
      desc: '',
      args: [],
    );
  }

  /// `Bank Name`
  String get bankName {
    return Intl.message('Bank Name', name: 'bankName', desc: '', args: []);
  }

  /// `Enter the bank name`
  String get enterBankName {
    return Intl.message(
      'Enter the bank name',
      name: 'enterBankName',
      desc: '',
      args: [],
    );
  }

  /// `IBAN Number`
  String get ibanNumber {
    return Intl.message('IBAN Number', name: 'ibanNumber', desc: '', args: []);
  }

  /// `Account Holder Name`
  String get accountHolderName {
    return Intl.message(
      'Account Holder Name',
      name: 'accountHolderName',
      desc: '',
      args: [],
    );
  }

  /// `Enter the full name as registered in the bank`
  String get enterFullBankName {
    return Intl.message(
      'Enter the full name as registered in the bank',
      name: 'enterFullBankName',
      desc: '',
      args: [],
    );
  }

  /// `Linked Phone Number`
  String get linkedPhoneNumber {
    return Intl.message(
      'Linked Phone Number',
      name: 'linkedPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter the phone number registered with the bank`
  String get enterRegisteredPhone {
    return Intl.message(
      'Enter the phone number registered with the bank',
      name: 'enterRegisteredPhone',
      desc: '',
      args: [],
    );
  }

  /// `Proof of Bank Account Ownership`
  String get proofOfOwnership {
    return Intl.message(
      'Proof of Bank Account Ownership',
      name: 'proofOfOwnership',
      desc: '',
      args: [],
    );
  }

  /// `Tap here to upload a photo of the bank statement or bank card`
  String get tapToUpload {
    return Intl.message(
      'Tap here to upload a photo of the bank statement or bank card',
      name: 'tapToUpload',
      desc: '',
      args: [],
    );
  }

  /// `Under Review`
  String get underReview {
    return Intl.message(
      'Under Review',
      name: 'underReview',
      desc: '',
      args: [],
    );
  }

  /// `Submit for Review`
  String get submitForReview {
    return Intl.message(
      'Submit for Review',
      name: 'submitForReview',
      desc: '',
      args: [],
    );
  }

  /// `Bank account details submitted successfully`
  String get bankSubmittedSuccessfully {
    return Intl.message(
      'Bank account details submitted successfully',
      name: 'bankSubmittedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get fieldRequired {
    return Intl.message(
      'This field is required',
      name: 'fieldRequired',
      desc: '',
      args: [],
    );
  }

  /// `Our Services`
  String get ourServices {
    return Intl.message(
      'Our Services',
      name: 'ourServices',
      desc: '',
      args: [],
    );
  }

  /// `New Orders`
  String get newOrders {
    return Intl.message('New Orders', name: 'newOrders', desc: '', args: []);
  }

  /// `Cancelled Orders`
  String get cancelledOrders {
    return Intl.message(
      'Cancelled Orders',
      name: 'cancelledOrders',
      desc: '',
      args: [],
    );
  }

  /// `Financial Accounts`
  String get FinancialAccounts {
    return Intl.message(
      'Financial Accounts',
      name: 'FinancialAccounts',
      desc: '',
      args: [],
    );
  }

  /// `Ad Posting Terms`
  String get adTermsTitle {
    return Intl.message(
      'Ad Posting Terms',
      name: 'adTermsTitle',
      desc: '',
      args: [],
    );
  }

  /// `- The product must be real and match the displayed photos.\n- The ad must contain a clear and accurate description of the product.\n- Photos must be recent, clear, and truthful.\n- Fake or duplicate products are prohibited.\n- The ad will be reviewed before final publication.\n- In case of violation, the administration reserves the right to delete the ad without prior notice.`
  String get adTermsContent {
    return Intl.message(
      '- The product must be real and match the displayed photos.\n- The ad must contain a clear and accurate description of the product.\n- Photos must be recent, clear, and truthful.\n- Fake or duplicate products are prohibited.\n- The ad will be reviewed before final publication.\n- In case of violation, the administration reserves the right to delete the ad without prior notice.',
      name: 'adTermsContent',
      desc: '',
      args: [],
    );
  }

  /// `I have read and agree to the above advertisement terms.`
  String get agreeToTerms {
    return Intl.message(
      'I have read and agree to the above advertisement terms.',
      name: 'agreeToTerms',
      desc: '',
      args: [],
    );
  }

  /// `You must accept the terms before continuing.`
  String get mustAcceptTerms {
    return Intl.message(
      'You must accept the terms before continuing.',
      name: 'mustAcceptTerms',
      desc: '',
      args: [],
    );
  }

  /// `Add Advertisement`
  String get addAd {
    return Intl.message('Add Advertisement', name: 'addAd', desc: '', args: []);
  }

  /// `My Store`
  String get appName {
    return Intl.message('My Store', name: 'appName', desc: '', args: []);
  }

  /// `Edit Ad`
  String get editAd {
    return Intl.message('Edit Ad', name: 'editAd', desc: '', args: []);
  }

  /// `Product Name`
  String get productName {
    return Intl.message(
      'Product Name',
      name: 'productName',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get quantity {
    return Intl.message('Quantity', name: 'quantity', desc: '', args: []);
  }

  /// `Currency`
  String get currency {
    return Intl.message('Currency', name: 'currency', desc: '', args: []);
  }

  /// `Price`
  String get price {
    return Intl.message('Price', name: 'price', desc: '', args: []);
  }

  /// `Product Description`
  String get productDescription {
    return Intl.message(
      'Product Description',
      name: 'productDescription',
      desc: '',
      args: [],
    );
  }

  /// `Write the product description here...`
  String get writeDescription {
    return Intl.message(
      'Write the product description here...',
      name: 'writeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Images (max 10)`
  String get imagesMax10 {
    return Intl.message(
      'Images (max 10)',
      name: 'imagesMax10',
      desc: '',
      args: [],
    );
  }

  /// `Add Images`
  String get addImages {
    return Intl.message('Add Images', name: 'addImages', desc: '', args: []);
  }

  /// `Shipping Options`
  String get shippingOptions {
    return Intl.message(
      'Shipping Options',
      name: 'shippingOptions',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get none {
    return Intl.message('None', name: 'none', desc: '', args: []);
  }

  /// `Local`
  String get local {
    return Intl.message('Local', name: 'local', desc: '', args: []);
  }

  /// `Local & International`
  String get localAndInternational {
    return Intl.message(
      'Local & International',
      name: 'localAndInternational',
      desc: '',
      args: [],
    );
  }

  /// `Installment Available?`
  String get installmentAvailable {
    return Intl.message(
      'Installment Available?',
      name: 'installmentAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Post Ad`
  String get postAd {
    return Intl.message('Post Ad', name: 'postAd', desc: '', args: []);
  }

  /// `Save Changes`
  String get saveChanges {
    return Intl.message(
      'Save Changes',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Incomplete Data`
  String get incompleteData {
    return Intl.message(
      'Incomplete Data',
      name: 'incompleteData',
      desc: '',
      args: [],
    );
  }

  /// `Please fill in all required fields.`
  String get fillRequiredFields {
    return Intl.message(
      'Please fill in all required fields.',
      name: 'fillRequiredFields',
      desc: '',
      args: [],
    );
  }

  /// `Image Limit`
  String get imageLimit {
    return Intl.message('Image Limit', name: 'imageLimit', desc: '', args: []);
  }

  /// `You can’t add more than 10 images.`
  String get max10Images {
    return Intl.message(
      'You can’t add more than 10 images.',
      name: 'max10Images',
      desc: '',
      args: [],
    );
  }

  /// `Added`
  String get added {
    return Intl.message('Added', name: 'added', desc: '', args: []);
  }

  /// `You’ve reached the maximum number of 10 images.`
  String get maxImagesReached {
    return Intl.message(
      'You’ve reached the maximum number of 10 images.',
      name: 'maxImagesReached',
      desc: '',
      args: [],
    );
  }

  /// `Posted Successfully`
  String get postedSuccessfully {
    return Intl.message(
      'Posted Successfully',
      name: 'postedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Your ad has been posted successfully!`
  String get adPosted {
    return Intl.message(
      'Your ad has been posted successfully!',
      name: 'adPosted',
      desc: '',
      args: [],
    );
  }

  /// `Edited Successfully`
  String get editedSuccessfully {
    return Intl.message(
      'Edited Successfully',
      name: 'editedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `The ad has been updated successfully!`
  String get adUpdated {
    return Intl.message(
      'The ad has been updated successfully!',
      name: 'adUpdated',
      desc: '',
      args: [],
    );
  }

  /// `After selling this quantity, the product will be automatically removed.`
  String get afterSellingQuantity {
    return Intl.message(
      'After selling this quantity, the product will be automatically removed.',
      name: 'afterSellingQuantity',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Choose currency`
  String get chooseCurrency {
    return Intl.message(
      'Choose currency',
      name: 'chooseCurrency',
      desc: '',
      args: [],
    );
  }

  /// `My Store`
  String get myStore {
    return Intl.message('My Store', name: 'myStore', desc: '', args: []);
  }

  /// `No ads yet`
  String get noAdsYet {
    return Intl.message('No ads yet', name: 'noAdsYet', desc: '', args: []);
  }

  /// `Confirmed`
  String get confirmed {
    return Intl.message('Confirmed', name: 'confirmed', desc: '', args: []);
  }

  /// `Shipped`
  String get shipped {
    return Intl.message('Shipped', name: 'shipped', desc: '', args: []);
  }

  /// `Delivered`
  String get delivered {
    return Intl.message('Delivered', name: 'delivered', desc: '', args: []);
  }

  /// `Confirm {action}`
  String confirmAction(Object action) {
    return Intl.message(
      'Confirm $action',
      name: 'confirmAction',
      desc: '',
      args: [action],
    );
  }

  /// `Are you sure you want to perform this action?`
  String get confirmActionMessage {
    return Intl.message(
      'Are you sure you want to perform this action?',
      name: 'confirmActionMessage',
      desc: '',
      args: [],
    );
  }

  /// `SAR`
  String get sar {
    return Intl.message('SAR', name: 'sar', desc: '', args: []);
  }

  /// `Confirming the order will notify the customer immediately`
  String get orderPendingMessage {
    return Intl.message(
      'Confirming the order will notify the customer immediately',
      name: 'orderPendingMessage',
      desc: '',
      args: [],
    );
  }

  /// `Order cancelled by customer`
  String get orderCancelledByCustomer {
    return Intl.message(
      'Order cancelled by customer',
      name: 'orderCancelledByCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Ship`
  String get ship {
    return Intl.message('Ship', name: 'ship', desc: '', args: []);
  }

  /// `Confirm Order`
  String get confirmOrder {
    return Intl.message(
      'Confirm Order',
      name: 'confirmOrder',
      desc: '',
      args: [],
    );
  }

  /// `Ship Order`
  String get shipOrder {
    return Intl.message('Ship Order', name: 'shipOrder', desc: '', args: []);
  }

  /// `Mark as Delivered`
  String get markAsDelivered {
    return Intl.message(
      'Mark as Delivered',
      name: 'markAsDelivered',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get confirmedOrders {
    return Intl.message(
      'Confirmed',
      name: 'confirmedOrders',
      desc: '',
      args: [],
    );
  }

  /// `Shipped`
  String get shippedOrders {
    return Intl.message('Shipped', name: 'shippedOrders', desc: '', args: []);
  }

  /// `Delivered`
  String get deliveredOrders {
    return Intl.message(
      'Delivered',
      name: 'deliveredOrders',
      desc: '',
      args: [],
    );
  }

  /// `New Orders`
  String get sellerNewOrders {
    return Intl.message(
      'New Orders',
      name: 'sellerNewOrders',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled Orders`
  String get sellerCancelledOrders {
    return Intl.message(
      'Cancelled Orders',
      name: 'sellerCancelledOrders',
      desc: '',
      args: [],
    );
  }

  /// `Active Orders`
  String get sellerActiveOrders {
    return Intl.message(
      'Active Orders',
      name: 'sellerActiveOrders',
      desc: '',
      args: [],
    );
  }

  /// `Profit Details`
  String get profitDetails {
    return Intl.message(
      'Profit Details',
      name: 'profitDetails',
      desc: '',
      args: [],
    );
  }

  /// `No data available`
  String get noData {
    return Intl.message(
      'No data available',
      name: 'noData',
      desc: '',
      args: [],
    );
  }

  /// `Order ID`
  String get orderId {
    return Intl.message('Order ID', name: 'orderId', desc: '', args: []);
  }

  /// `Amount`
  String get amount {
    return Intl.message('Amount', name: 'amount', desc: '', args: []);
  }

  /// `Code`
  String get code {
    return Intl.message('Code', name: 'code', desc: '', args: []);
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `Date`
  String get date {
    return Intl.message('Date', name: 'date', desc: '', args: []);
  }

  /// `Profit Report`
  String get profitReport {
    return Intl.message(
      'Profit Report',
      name: 'profitReport',
      desc: '',
      args: [],
    );
  }

  /// `Subscription Details`
  String get subscriptionDetails {
    return Intl.message(
      'Subscription Details',
      name: 'subscriptionDetails',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get duration {
    return Intl.message('Duration', name: 'duration', desc: '', args: []);
  }

  /// `Choose Payment Method`
  String get choosePaymentMethod {
    return Intl.message(
      'Choose Payment Method',
      name: 'choosePaymentMethod',
      desc: '',
      args: [],
    );
  }

  /// `Pay with your Visa card`
  String get payWithVisa {
    return Intl.message(
      'Pay with your Visa card',
      name: 'payWithVisa',
      desc: '',
      args: [],
    );
  }

  /// `MasterCard`
  String get masterCard {
    return Intl.message('MasterCard', name: 'masterCard', desc: '', args: []);
  }

  /// `Pay with your MasterCard`
  String get payWithMasterCard {
    return Intl.message(
      'Pay with your MasterCard',
      name: 'payWithMasterCard',
      desc: '',
      args: [],
    );
  }

  /// `Pay Now`
  String get payNow {
    return Intl.message('Pay Now', name: 'payNow', desc: '', args: []);
  }

  /// `Monthly Orders`
  String get ordersMonthly {
    return Intl.message(
      'Monthly Orders',
      name: 'ordersMonthly',
      desc: '',
      args: [],
    );
  }

  /// `Months`
  String get months {
    return Intl.message('Months', name: 'months', desc: '', args: []);
  }

  /// `Monthly Orders`
  String get monthlyOrders {
    return Intl.message(
      'Monthly Orders',
      name: 'monthlyOrders',
      desc: '',
      args: [],
    );
  }

  /// `Referral Code`
  String get ReferralCode {
    return Intl.message(
      'Referral Code',
      name: 'ReferralCode',
      desc: '',
      args: [],
    );
  }

  /// `m²`
  String get M {
    return Intl.message('m²', name: 'M', desc: '', args: []);
  }

  /// `Pending`
  String get pending {
    return Intl.message('Pending', name: 'pending', desc: '', args: []);
  }

  /// `Paid`
  String get paid {
    return Intl.message('Paid', name: 'paid', desc: '', args: []);
  }

  /// `Delete Ad`
  String get deleteAdTitle {
    return Intl.message('Delete Ad', name: 'deleteAdTitle', desc: '', args: []);
  }

  /// `Are you sure you want to permanently delete this ad?`
  String get deleteAdContent {
    return Intl.message(
      'Are you sure you want to permanently delete this ad?',
      name: 'deleteAdContent',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `Link Error`
  String get linkErrorTitle {
    return Intl.message(
      'Link Error',
      name: 'linkErrorTitle',
      desc: '',
      args: [],
    );
  }

  /// `Ad not found`
  String get adNotFound {
    return Intl.message('Ad not found', name: 'adNotFound', desc: '', args: []);
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
