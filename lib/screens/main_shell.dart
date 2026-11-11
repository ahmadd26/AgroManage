import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/custom_widgets.dart';
import 'dashboard_screen.dart';
import 'pos_screen.dart';
import 'products_screen.dart';
import 'product_detail_screen.dart';
import 'add_product_screen.dart';
import 'customers_screen.dart';
import 'customer_detail_screen.dart';
import 'add_customer_screen.dart';
import 'invoices_screen.dart';
import 'invoice_detail_screen.dart';
import 'installments_screen.dart';
import 'record_payment_screen.dart';
import 'purchases_screen.dart';
import 'new_purchase_screen.dart';
import 'suppliers_screen.dart';
import 'reports_screen.dart';
import 'expenses_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';

class MainShell extends StatefulWidget {
  final AppState state;
  final VoidCallback onLogout;

  const MainShell({
    super.key,
    required this.state,
    required this.onLogout,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  String _currentRoute = 'dashboard';
  int _bottomNavIndex = 0;

  // Selected item IDs for detail screens
  String? _selectedProductId;
  String? _selectedCustomerId;
  String? _selectedInvoiceNo;

  void _navigateTo(String route) {
    if (route == 'login') {
      widget.onLogout();
      return;
    }

    setState(() {
      _currentRoute = route;
      if (route == 'dashboard') {
        _bottomNavIndex = 0;
      } else if (route == 'pos') {
        _bottomNavIndex = 1;
      } else if (route == 'products') {
        _bottomNavIndex = 2;
      } else if (route == 'customers') {
        _bottomNavIndex = 3;
      } else if (route == 'invoices') {
        _bottomNavIndex = 4;
      }
    });
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
      switch (index) {
        case 0:
          _currentRoute = 'dashboard';
          break;
        case 1:
          _currentRoute = 'pos';
          break;
        case 2:
          _currentRoute = 'products';
          break;
        case 3:
          _currentRoute = 'customers';
          break;
        case 4:
          _currentRoute = 'invoices';
          break;
      }
    });
  }

  Widget _buildBody() {
    final state = widget.state;

    switch (_currentRoute) {
      case 'dashboard':
        return DashboardScreen(
          state: state,
          onNavigate: _navigateTo,
          onViewInvoice: (invNo) {
            setState(() {
              _selectedInvoiceNo = invNo;
              _currentRoute = 'invoice_detail';
            });
          },
          onViewCustomer: (custId) {
            setState(() {
              _selectedCustomerId = custId;
              _currentRoute = 'customer_detail';
            });
          },
        );

      case 'pos':
        return PosScreen(
          state: state,
          onInvoiceGenerated: (invNo) {
            setState(() {
              _selectedInvoiceNo = invNo;
              _currentRoute = 'invoice_detail';
            });
          },
          onAddCustomer: () => _navigateTo('add_customer'),
        );

      case 'products':
        return ProductsScreen(
          state: state,
          onSelectProduct: (id) {
            setState(() {
              _selectedProductId = id;
              _currentRoute = 'product_detail';
            });
          },
          onAddProduct: () => _navigateTo('add_product'),
        );

      case 'product_detail':
        return ProductDetailScreen(
          productId: _selectedProductId ?? state.products.first.id,
          state: state,
          onBack: () => _navigateTo('products'),
          onEditProduct: (id) => _navigateTo('edit_product'),
          onSellProduct: () => _navigateTo('pos'),
        );

      case 'add_product':
        return AddProductScreen(
          state: state,
          onSaved: () => _navigateTo('products'),
          onCancel: () => _navigateTo('products'),
        );

      case 'edit_product':
        return AddProductScreen(
          state: state,
          editProductId: _selectedProductId,
          onSaved: () => _navigateTo('product_detail'),
          onCancel: () => _navigateTo('product_detail'),
        );

      case 'customers':
        return CustomersScreen(
          state: state,
          onSelectCustomer: (id) {
            setState(() {
              _selectedCustomerId = id;
              _currentRoute = 'customer_detail';
            });
          },
          onAddCustomer: () => _navigateTo('add_customer'),
        );

      case 'customer_detail':
        return CustomerDetailScreen(
          customerId: _selectedCustomerId ?? state.customers.first.id,
          state: state,
          onBack: () => _navigateTo('customers'),
          onViewInvoice: (invNo) {
            setState(() {
              _selectedInvoiceNo = invNo;
              _currentRoute = 'invoice_detail';
            });
          },
          onRecordPayment: (invNo) {
            setState(() {
              _selectedInvoiceNo = invNo;
              _currentRoute = 'record_payment';
            });
          },
          onNewSaleForCustomer: (cust) {
            state.selectedCustomer = cust;
            _navigateTo('pos');
          },
        );

      case 'add_customer':
        return AddCustomerScreen(
          state: state,
          onSaved: () => _navigateTo('customers'),
          onCancel: () => _navigateTo('customers'),
        );

      case 'invoices':
        return InvoicesScreen(
          state: state,
          onViewInvoice: (invNo) {
            setState(() {
              _selectedInvoiceNo = invNo;
              _currentRoute = 'invoice_detail';
            });
          },
          onNewSale: () => _navigateTo('pos'),
        );

      case 'invoice_detail':
        return InvoiceDetailScreen(
          invoiceNo: _selectedInvoiceNo ?? state.invoices.first.invoiceNo,
          state: state,
          onBack: () => _navigateTo('invoices'),
          onRecordPayment: (invNo) {
            setState(() {
              _selectedInvoiceNo = invNo;
              _currentRoute = 'record_payment';
            });
          },
        );

      case 'installments':
        return InstallmentsScreen(
          state: state,
          onRecordPayment: (invNo) {
            setState(() {
              _selectedInvoiceNo = invNo;
              _currentRoute = 'record_payment';
            });
          },
          onViewInvoice: (invNo) {
            setState(() {
              _selectedInvoiceNo = invNo;
              _currentRoute = 'invoice_detail';
            });
          },
        );

      case 'record_payment':
        return RecordPaymentScreen(
          state: state,
          initialInvoiceNo: _selectedInvoiceNo,
          onPaymentRecorded: () => _navigateTo('invoices'),
          onCancel: () => _navigateTo('invoices'),
        );

      case 'purchases':
        return PurchasesScreen(
          state: state,
          onNewPurchase: () => _navigateTo('new_purchase'),
          onSelectSupplier: (sId) => _navigateTo('suppliers'),
        );

      case 'new_purchase':
        return NewPurchaseScreen(
          state: state,
          onSaved: () => _navigateTo('purchases'),
          onCancel: () => _navigateTo('purchases'),
        );

      case 'suppliers':
        return SuppliersScreen(
          state: state,
          onSelectSupplier: (_) {},
        );

      case 'reports':
        return ReportsScreen(state: state);

      case 'expenses':
        return ExpensesScreen(state: state);

      case 'settings':
        return SettingsScreen(state: state);

      case 'notifications':
        return NotificationsScreen(
          state: state,
          onSelectProduct: (pId) {
            setState(() {
              _selectedProductId = pId;
              _currentRoute = 'product_detail';
            });
          },
          onViewInvoice: (invNo) {
            setState(() {
              _selectedInvoiceNo = invNo;
              _currentRoute = 'invoice_detail';
            });
          },
          onNewPurchase: () => _navigateTo('new_purchase'),
        );

      default:
        return DashboardScreen(
          state: state,
          onNavigate: _navigateTo,
          onViewInvoice: (_) {},
          onViewCustomer: (_) {},
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showBottomNav = [
      'dashboard',
      'pos',
      'products',
      'customers',
      'invoices',
      'installments',
      'purchases',
      'suppliers',
      'reports',
      'expenses',
      'settings',
      'notifications'
    ].contains(_currentRoute);

    return Scaffold(
      drawer: AppDrawer(
        state: widget.state,
        currentRoute: _currentRoute,
        onNavigate: _navigateTo,
      ),
      body: _buildBody(),
      bottomNavigationBar: showBottomNav
          ? NavigationBar(
              selectedIndex: _bottomNavIndex,
              onDestinationSelected: _onBottomNavTapped,
              indicatorColor: AppTheme.primaryGreenLight,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard, color: AppTheme.primaryGreenDark),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.point_of_sale_outlined),
                  selectedIcon: Icon(Icons.point_of_sale, color: AppTheme.primaryGreenDark),
                  label: 'POS Sale',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2, color: AppTheme.primaryGreenDark),
                  label: 'Stock',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people, color: AppTheme.primaryGreenDark),
                  label: 'Farmers',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long, color: AppTheme.primaryGreenDark),
                  label: 'Bills',
                ),
              ],
            )
          : null,
    );
  }
}
