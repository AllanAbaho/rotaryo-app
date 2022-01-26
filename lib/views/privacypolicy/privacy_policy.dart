import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/text.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppbar(context, title: 'Privacy Policy'),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Insets.lg, vertical: Insets.md),
            child: SmallText(_note),
          ),
        ));
  }
}

const _note = '''
Pivot Payments under the Tumia Pesa Brand is 
committed to protect our customers’ personal 
information and/or sensitive personal data and strive 
to maintain the privacy of your personal information.
“Personal information” is any information that can be 
used by itself to uniquely identify, or contact or know 
the customer preferences of an individual. For the 
purpose of this policy, sensitive personal data or 
information has been considered as a part of personal 
information.

Tumia Pesa does collect your personal information 
for a variety of regulatory and business purposes. 
These include, but are not limited to:

Verify your identity, Complete transactions effectively
and bill for products and services, Respond to your 
request for service or assistance, Perform business and 
operational analysis, Provide, maintain and improve 
our products and services, Anticipate and resolve 
issues and concerns with our products and services, 
Promote and market our products and services which 
we consider may be of interest to you and may benefit 
you;
Ensure adherence to legal and regulatory 
requirements for prevention and detection of frauds 
and crimes.
Our Privacy Policy is designed and 
developed to address the privacy and security of your 
personal information provided to us. This Privacy Policy 
describes the personal information which we may 
collect and provides our approach towards handling 
or dealing with the same.

Collection Of Personal Information 

You agree that Pivot Payments and its authorized third
 parties will collect information pertaining to your 
identity, demographics, contact details, service 
utilization and payment details etc. For the purposes 
of this document, a ‘Third Party’ is a service provider 
who associates with Tumia Pesa and is involved in 
handling, managing, storing, processing, protecting 
and transmitting information of Tumia Pesa.

This definition also includes all sub-contractors, 
consultants and/or representatives of the Third party.
You agree that we may also collect your personal 
information when you use our services or Mobile Apps 
or otherwise interact with us during the course of our 
relationship.

Personal information collected and held by us may 
include your name, mobile phone number, and email 
address etc. Tumia Pesa and its authorized third 
parties collect, store, process following types of 
Sensitive Personal Information such as password, 
transaction details, physiological information for 
providing our products, services and for use of our 
Mobile App. We may also hold information related to 
your utilization of our services which may include your 
browsing history on our Mobile App, transaction details 
and additional information provided by you while using 
our services.
In case you do not provide your information or consent 
for usage of personal information or later on withdraw 
your consent for usage of the personal information so
 collected, Tumia Pesa reserves the right to not provide 
the services or to withdraw the services for which the 
said information was sought.

''';
