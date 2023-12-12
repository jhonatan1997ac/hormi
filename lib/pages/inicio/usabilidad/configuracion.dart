import 'package:flutter/material.dart';

class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ConfiguracionItem(
              title: 'Notificaciones',
              subtitle: 'Habilitar o deshabilitar notificaciones',
              icon: Icons.notifications,
              onTap: () {
                _navigateToConfiguracionDetail(context, 'Notificaciones');
              },
            ),
            ConfiguracionItem(
              title: 'Idioma',
              subtitle: 'Seleccionar el idioma de la aplicación',
              icon: Icons.language,
              onTap: () {
                _navigateToConfiguracionDetail(context, 'Idioma');
              },
            ),
            ConfiguracionItem(
              title: 'Privacidad',
              subtitle: 'Configuración de privacidad',
              icon: Icons.security,
              onTap: () {
                _navigateToConfiguracionDetail(context, 'Privacidad');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToConfiguracionDetail(
      BuildContext context, String settingTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfiguracionDetailPage(title: settingTitle),
      ),
    );
  }
}

class ConfiguracionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const ConfiguracionItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}

class ConfiguracionDetailPage extends StatelessWidget {
  final String title;

  const ConfiguracionDetailPage({Key? key, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Configuración detallada para $title'),
      ),
    );
  }
}
