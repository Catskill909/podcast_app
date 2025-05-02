import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'social_circle_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PodcastDrawer extends StatelessWidget {
  const PodcastDrawer({Key? key}) : super(key: key);

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF18181B) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(46),
              offset: const Offset(8, 0), // subtle right shadow
              blurRadius: 24,
              spreadRadius: 0,
            ),
            if (isDark)
              const BoxShadow(
                color: Colors.black54,
                offset: Offset(4, 0),
                blurRadius: 16,
                spreadRadius: 2,
              ),
          ],
        ),
        width: 290,
        child: Drawer(
          backgroundColor: Colors.transparent,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Image.asset(
                          'assets/images/header.png',
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(
                        'About Pacifica',
                        style: GoogleFonts.oswald(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _launchURL(
                            'https://pacificanetwork.org/about-pacifica-foundation/pacifica-foundation/');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.mail_outline),
                      title: Text(
                        'Contact Us',
                        style: GoogleFonts.oswald(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _launchURL('https://pacificanetwork.org/contact/');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.link_outlined),
                      title: Text(
                        'Visit Website',
                        style: GoogleFonts.oswald(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _launchURL('https://pacificanetwork.org');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: Text(
                        'Privacy Policy',
                        style: GoogleFonts.oswald(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _launchURL('https://pacificanetwork.org');
                      },
                    ),
                  ],
                ),
              ),
              SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SocialCircleButton(
                            icon: FontAwesomeIcons.facebookF,
                            onTap: () {
                              Navigator.of(context).pop();
                              _launchURL('https://facebook.com/yourpage');
                            },
                            size: 36.0,
                          ),
                          const SizedBox(width: 16),
                          SocialCircleButton(
                            icon: FontAwesomeIcons.instagram,
                            onTap: () {
                              Navigator.of(context).pop();
                              _launchURL('https://instagram.com/yourpage');
                            },
                            size: 36.0,
                          ),
                          const SizedBox(width: 16),
                          SocialCircleButton(
                            icon: FontAwesomeIcons.twitter,
                            onTap: () {
                              Navigator.of(context).pop();
                              _launchURL('https://twitter.com/yourpage');
                            },
                            size: 36.0,
                          ),
                          const SizedBox(width: 16),
                          SocialCircleButton(
                            icon: FontAwesomeIcons.youtube,
                            onTap: () {
                              Navigator.of(context).pop();
                              _launchURL('https://youtube.com/yourpage');
                            },
                            size: 36.0,
                          ),
                          const SizedBox(width: 16),
                          SocialCircleButton(
                            icon: Icons.email_outlined,
                            onTap: () {
                              Navigator.of(context).pop();
                              _launchURL('mailto:your@email.com');
                            },
                            size: 36.0,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height:
                          MediaQuery.of(context).padding.bottom + 56 + 16 + 16,
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
