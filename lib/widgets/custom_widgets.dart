import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgTint;
  final String? subtitle;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgTint,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: bgTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String text;
  final String? type; // 'g' for green, 'r' for red, 'a' for amber, 'b' for blue

  const StatusBadge({
    super.key,
    required this.text,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    final lower = text.toLowerCase();
    if (type == 'g' || lower.contains('paid') || lower.contains('in stock') || lower.contains('clear')) {
      bg = AppTheme.primaryGreenLight;
      fg = AppTheme.primaryGreenDark;
    } else if (type == 'r' || lower.contains('overdue') || lower.contains('out of stock') || lower.contains('low stock')) {
      bg = AppTheme.alertRedLight;
      fg = AppTheme.alertRed;
    } else if (type == 'a' || lower.contains('pending') || lower.contains('expiring') || lower.contains('due')) {
      bg = AppTheme.accentAmberLight;
      fg = AppTheme.accentAmber;
    } else {
      bg = AppTheme.secondaryBlueLight;
      fg = AppTheme.secondaryBlue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class SalesBarChart extends StatelessWidget {
  const SalesBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final months = ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'];
    final values = [14.2, 18.6, 12.1, 9.8, 11.4, 21.5, 8.9]; // Lakh PKR
    const double maxVal = 24.0;

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(months.length, (i) {
              final double heightRatio = values[i] / maxVal;
              final bool isHighest = i == 5; // Sep peak season

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${values[i]}L',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isHighest ? AppTheme.primaryGreenDark : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 28,
                    height: (120 * heightRatio).clamp(10, 120),
                    decoration: BoxDecoration(
                      color: isHighest ? AppTheme.primaryGreen : AppTheme.secondaryBlue,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    months[i],
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: AppTheme.secondaryBlue, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 6),
            const Text('Regular Sales', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            const SizedBox(width: 16),
            Container(width: 10, height: 10, decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 6),
            const Text('Kharif Sowing Peak', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        )
      ],
    );
  }
}

class AppDrawer extends StatelessWidget {
  final AppState state;
  final String currentRoute;
  final Function(String) onNavigate;

  const AppDrawer({
    super.key,
    required this.state,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.lightLine)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.secondaryBlue, AppTheme.primaryGreen],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.eco, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.shopName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${state.ownerName} · Sahiwal',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                children: [
                  _drawerItem(context, Icons.dashboard_outlined, 'Dashboard', 'dashboard'),
                  _drawerItem(context, Icons.point_of_sale_outlined, 'New Sale (POS)', 'pos'),
                  _drawerItem(context, Icons.inventory_2_outlined, 'Products & Stock', 'products', badge: '${state.products.length}'),
                  _drawerItem(context, Icons.people_outline, 'Customers / Farmers', 'customers', badge: '${state.customers.length}'),
                  _drawerItem(context, Icons.receipt_long_outlined, 'Invoices & Bills', 'invoices', badge: '${state.invoices.length}'),
                  _drawerItem(context, Icons.credit_score_outlined, 'Installments (Khata)', 'installments', badge: '${state.overdueInvoices.length} overdue', badgeColor: AppTheme.alertRed),
                  _drawerItem(context, Icons.shopping_bag_outlined, 'Purchases (Stock In)', 'purchases'),
                  _drawerItem(context, Icons.local_shipping_outlined, 'Suppliers', 'suppliers'),
                  _drawerItem(context, Icons.bar_chart_outlined, 'Reports & Analytics', 'reports'),
                  _drawerItem(context, Icons.attach_money_outlined, 'Daily Expenses', 'expenses'),
                  _drawerItem(context, Icons.notifications_none_outlined, 'Alerts & Expiry', 'notifications', badge: '${state.lowStockProducts.length}', badgeColor: AppTheme.accentAmber),
                  const Divider(),
                  _drawerItem(context, Icons.settings_outlined, 'Shop Settings', 'settings'),
                  _drawerItem(context, Icons.logout, 'Sign Out', 'login', isDestructive: true),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dark Theme', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  Switch.adaptive(
                    value: state.themeMode == ThemeMode.dark,
                    onChanged: (_) => state.toggleTheme(),
                    activeTrackColor: AppTheme.primaryGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String route, {
    String? badge,
    Color? badgeColor,
    bool isDestructive = false,
  }) {
    final bool isSelected = currentRoute == route;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.secondaryBlueLight : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive
              ? AppTheme.alertRed
              : (isSelected ? AppTheme.secondaryBlue : AppTheme.textMuted),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isDestructive
                ? AppTheme.alertRed
                : (isSelected ? AppTheme.secondaryBlue : null),
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (badgeColor ?? AppTheme.secondaryBlue).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeColor ?? AppTheme.secondaryBlue,
                  ),
                ),
              )
            : null,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: () {
          Navigator.pop(context); // Close drawer
          onNavigate(route);
        },
      ),
    );
  }
}
