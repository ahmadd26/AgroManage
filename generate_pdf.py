import os
import sys
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, HRFlowable
)
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_header_footer(num_pages)
            super().showPage()
        super().save()

    def draw_header_footer(self, page_count):
        self.saveState()
        self.setFont("Helvetica-Bold", 8)
        self.setFillColor(colors.HexColor("#2E7D32"))
        
        # Header (Pages > 1)
        if self._pageNumber > 1:
            self.drawString(54, 752, "AgroManage – MAD Mid Lab Assessment Guide & Complete Screen Manual")
            self.setStrokeColor(colors.HexColor("#A5D6A7"))
            self.setLineWidth(0.6)
            self.line(54, 746, 558, 746)
            
        # Footer
        self.setFont("Helvetica", 8)
        self.setFillColor(colors.HexColor("#666666"))
        page_text = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(558, 36, page_text)
        self.drawString(54, 36, "AgroManage Kisan Center · Prepared for Lab Evaluation & Live Coding Viva")
        self.setStrokeColor(colors.HexColor("#CCCCCC"))
        self.setLineWidth(0.5)
        self.line(54, 46, 558, 46)
        
        self.restoreState()

def build_pdf(filename="AgroManage_Complete_Screens_and_Viva_Guide.pdf"):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )
    
    styles = getSampleStyleSheet()
    
    c_primary = colors.HexColor("#1B5E20")      # Forest Green
    c_secondary = colors.HexColor("#2E7D32")    # Primary Green
    c_dark = colors.HexColor("#212121")         # Text dark
    c_light_bg = colors.HexColor("#F1F8E9")     # Light green tint
    c_code_bg = colors.HexColor("#F9FBE7")      # Code light tint
    c_border = colors.HexColor("#C8E6C9")       # Border green
    
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Heading1'],
        fontSize=22,
        leading=26,
        textColor=c_primary,
        fontName='Helvetica-Bold',
        spaceAfter=4
    )
    
    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        parent=styles['Normal'],
        fontSize=11,
        leading=15,
        textColor=colors.HexColor("#555555"),
        spaceAfter=10
    )
    
    h1_style = ParagraphStyle(
        'Heading1_Custom',
        parent=styles['Heading1'],
        fontSize=14,
        leading=18,
        textColor=c_primary,
        fontName='Helvetica-Bold',
        spaceBefore=10,
        spaceAfter=6,
        keepWithNext=True
    )
    
    h2_style = ParagraphStyle(
        'Heading2_Custom',
        parent=styles['Heading2'],
        fontSize=11,
        leading=15,
        textColor=c_secondary,
        fontName='Helvetica-Bold',
        spaceBefore=8,
        spaceAfter=4,
        keepWithNext=True
    )

    body_style = ParagraphStyle(
        'Body_Custom',
        parent=styles['Normal'],
        fontSize=9,
        leading=13,
        textColor=c_dark,
        spaceAfter=4
    )

    code_style = ParagraphStyle(
        'Code_Custom',
        parent=styles['Normal'],
        fontSize=8,
        leading=11,
        fontName='Courier',
        textColor=colors.HexColor("#0D47A1"),
        backColor=c_code_bg,
        borderPadding=5,
        spaceBefore=3,
        spaceAfter=5
    )
    
    box_style = ParagraphStyle(
        'CalloutText',
        parent=styles['Normal'],
        fontSize=8.5,
        leading=12,
        textColor=colors.HexColor("#1B5E20"),
    )
    
    story = []

    # ==================== COVER / HEADER ====================
    story.append(Paragraph("AgroManage – Complete Project & Viva Guide", title_style))
    story.append(Paragraph("Full Screens Catalog, Project Architecture, and Live Coding Handbook for Mobile Application Development (MAD) Mid Lab Assessment", subtitle_style))
    story.append(HRFlowable(width="100%", thickness=1.5, color=c_primary, spaceAfter=10))

    meta_data = [
        [Paragraph("<b>Course:</b> Mobile Application Development (MAD)", body_style), Paragraph("<b>Tech Stack:</b> Flutter 3.47 / Dart 3.13", body_style)],
        [Paragraph("<b>Project:</b> AgroManage (Kisan Agro Center)", body_style), Paragraph("<b>State Management:</b> ChangeNotifier (AppState)", body_style)],
        [Paragraph("<b>Platform:</b> Android (API 34/36, minSdk 21)", body_style), Paragraph("<b>Repository:</b> github.com/ahmadd26/AgroManage", body_style)],
    ]
    meta_table = Table(meta_data, colWidths=[250, 254])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), c_light_bg),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 10))

    # ==================== SECTION 1 ====================
    story.append(Paragraph("1. Project Architecture & File Organization", h1_style))
    story.append(Paragraph("In Flutter, code is organized inside the <code>lib/</code> folder. Here is the directory layout of AgroManage and the role of each directory:", body_style))

    arch_data = [
        [Paragraph("<b>Directory / File</b>", body_style), Paragraph("<b>Purpose & Contents</b>", body_style)],
        [Paragraph("<code>lib/main.dart</code>", code_style), Paragraph("<b>Application Entry Point.</b> Contains <code>main()</code>, <code>runApp()</code>, initializes <code>AgroManageApp</code>, and manages the initial routing (Splash -> Login -> MainShell).", body_style)],
        [Paragraph("<code>lib/models/</code>", code_style), Paragraph("<b>Data Entities / Blueprints.</b> Plain Dart classes: <code>Product</code>, <code>Customer</code>, <code>SaleInvoice</code>, <code>InstallmentPlan</code>, <code>Supplier</code>, and <code>Expense</code>.", body_style)],
        [Paragraph("<code>lib/state/app_state.dart</code>", code_style), Paragraph("<b>Global State Management.</b> Extends <code>ChangeNotifier</code>. Holds in-memory lists, mock data, and business logic (adding products, invoices, recording payments, deducting stock).", body_style)],
        [Paragraph("<code>lib/theme/app_theme.dart</code>", code_style), Paragraph("<b>App Styling & Colors.</b> Agriculture green palette (<code>#2E7D32</code>), typography, button themes, card themes, and currency formatters (PKR).", body_style)],
        [Paragraph("<code>lib/widgets/custom_widgets.dart</code>", code_style), Paragraph("<b>Reusable UI Components.</b> <code>MetricCard</code> (dashboard stats), <code>StatusBadge</code> (colored tags), and <code>SectionHeader</code>.", body_style)],
        [Paragraph("<code>lib/screens/</code>", code_style), Paragraph("<b>UI Pages (22 screens).</b> All interactive screens: Dashboard, POS, Products, Customers, Khata Installments, Suppliers, Expenses, Reports, etc.", body_style)],
    ]
    arch_table = Table(arch_data, colWidths=[130, 374])
    arch_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_light_bg),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#DDDDDD")),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#EEEEEE")),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
    ]))
    story.append(arch_table)
    story.append(Spacer(1, 10))

    # ==================== SECTION 2 ====================
    story.append(Paragraph("2. Essential Flutter Concepts for Live Coding", h1_style))
    story.append(Paragraph("The examiner may ask you to recreate or modify code live during your viva. Below are the core concepts you must know:", body_style))

    # A
    story.append(Paragraph("A. How to Change the Starting Screen", h2_style))
    story.append(Paragraph("The starting screen is controlled by the <code>home:</code> property of <code>MaterialApp</code> in <code>lib/main.dart</code>:", body_style))
    story.append(Paragraph("""MaterialApp(<br/>
&nbsp;&nbsp;title: 'AgroManage',<br/>
&nbsp;&nbsp;theme: AppTheme.lightTheme,<br/>
&nbsp;&nbsp;home: SplashScreen(onFinish: () { ... }), // &lt;-- CHANGE THIS to test any screen!<br/>
&nbsp;&nbsp;// e.g. home: ProductsScreen(state: _appState, onSelectProduct: ...),<br/>
);""", code_style))

    # B
    story.append(Paragraph("B. Creating a StatelessWidget vs StatefulWidget", h2_style))
    story.append(Paragraph("• <b>StatelessWidget:</b> Used when the screen only displays data and does NOT change dynamically (e.g. static card, info dialog).<br/>• <b>StatefulWidget:</b> Used when user interaction changes data dynamically (e.g. form fields, checkboxes, counters, timers).", body_style))
    
    story.append(Paragraph("""// 1. STATELESS WIDGET:<br/>
class MyInfoCard extends StatelessWidget {<br/>
&nbsp;&nbsp;final String title;<br/>
&nbsp;&nbsp;const MyInfoCard({super.key, required this.title});<br/>
<br/>
&nbsp;&nbsp;@override<br/>
&nbsp;&nbsp;Widget build(BuildContext context) {<br/>
&nbsp;&nbsp;&nbsp;&nbsp;return Card(<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;child: Padding(<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;padding: const EdgeInsets.all(16.0),<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;child: Text(title, style: const TextStyle(fontSize: 16)),<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;),<br/>
&nbsp;&nbsp;&nbsp;&nbsp;);<br/>
&nbsp;&nbsp;}<br/>
}<br/>
<br/>
// 2. STATEFUL WIDGET:<br/>
class CounterScreen extends StatefulWidget {<br/>
&nbsp;&nbsp;const CounterScreen({super.key});<br/>
&nbsp;&nbsp;@override<br/>
&nbsp;&nbsp;State&lt;CounterScreen&gt; createState() =&gt; _CounterScreenState();<br/>
}<br/>
<br/>
class _CounterScreenState extends State&lt;CounterScreen&gt; {<br/>
&nbsp;&nbsp;int _count = 0;<br/>
<br/>
&nbsp;&nbsp;@override<br/>
&nbsp;&nbsp;Widget build(BuildContext context) {<br/>
&nbsp;&nbsp;&nbsp;&nbsp;return Scaffold(<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;appBar: AppBar(title: const Text('Counter')),<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;body: Center(child: Text('Count: $_count')),<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;floatingActionButton: FloatingActionButton(<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;onPressed: () {<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;setState(() { _count++; }); // setState tells Flutter to re-render build()!<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;},<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;child: const Icon(Icons.add),<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;),<br/>
&nbsp;&nbsp;&nbsp;&nbsp;);<br/>
&nbsp;&nbsp;}<br/>
}""", code_style))

    # C
    story.append(Paragraph("C. How to Add an Image from Scratch", h2_style))
    story.append(Paragraph("<b>Step 1:</b> Create folder <code>assets/images/</code> in project root and put your image there (e.g. <code>logo.png</code>).<br/>"
                           "<b>Step 2:</b> Register the asset in <code>pubspec.yaml</code> under <code>flutter:</code>:<br/>"
                           "&nbsp;&nbsp;<code>flutter:</code><br/>"
                           "&nbsp;&nbsp;&nbsp;&nbsp;<code>assets:</code><br/>"
                           "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<code>- assets/images/</code><br/>"
                           "<b>Step 3:</b> Run <code>flutter pub get</code>.<br/>"
                           "<b>Step 4:</b> In your Dart file, display it with <code>Image.asset()</code> or <code>Image.network()</code>:", body_style))
    story.append(Paragraph("""// Display Local Asset Image:<br/>
Image.asset('assets/images/logo.png', width: 100, height: 100, fit: BoxFit.cover)<br/>
<br/>
// Display Network Image (from URL):<br/>
Image.network('https://example.com/fertilizer.jpg', width: 100, height: 100)""", code_style))

    # D
    story.append(Paragraph("D. How to Navigate Between Screens", h2_style))
    story.append(Paragraph("Flutter manages navigation using a stack. <code>Navigator.push</code> adds a screen; <code>Navigator.pop</code> closes it:", body_style))
    story.append(Paragraph("""// 1. Open a new screen (Push):<br/>
Navigator.push(context, MaterialPageRoute(builder: (context) =&gt; AddProductScreen(state: appState)));<br/>
<br/>
// 2. Go back to previous screen (Pop):<br/>
Navigator.pop(context);<br/>
<br/>
// 3. Replace screen without back button (Login -&gt; MainShell):<br/>
Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =&gt; MainShell(state: appState)));""", code_style))

    # E
    story.append(Paragraph("E. How to Import Files & Screens", h2_style))
    story.append(Paragraph("""// Relative Import (based on current folder depth):<br/>
import '../models/product.dart';&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;// Up one folder to models<br/>
import '../screens/dashboard_screen.dart'; // Up one folder to screens<br/>
import 'package:flutter/material.dart';&nbsp;&nbsp;&nbsp;&nbsp; // Flutter core framework<br/>
<br/>
// Package Import (using app name from pubspec.yaml):<br/>
import 'package:agro_manage/models/customer.dart';""", code_style))

    # F
    story.append(Paragraph("F. Form Validation & Text Controllers", h2_style))
    story.append(Paragraph("""final _formKey = GlobalKey&lt;FormState&gt;();<br/>
final _nameCtrl = TextEditingController();<br/>
<br/>
@override<br/>
void dispose() {<br/>
&nbsp;&nbsp;_nameCtrl.dispose(); // Always dispose controllers to prevent memory leaks!<br/>
&nbsp;&nbsp;super.dispose();<br/>
}<br/>
<br/>
// In build():<br/>
Form(<br/>
&nbsp;&nbsp;key: _formKey,<br/>
&nbsp;&nbsp;child: Column(children: [<br/>
&nbsp;&nbsp;&nbsp;&nbsp;TextFormField(<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;controller: _nameCtrl,<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;decoration: const InputDecoration(labelText: 'Customer Name *'),<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;validator: (v) =&gt; (v == null || v.trim().isEmpty) ? 'Name required' : null,<br/>
&nbsp;&nbsp;&nbsp;&nbsp;),<br/>
&nbsp;&nbsp;&nbsp;&nbsp;ElevatedButton(<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;onPressed: () {<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (_formKey.currentState!.validate()) {<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;print('Entered Name: ${_nameCtrl.text}');<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;},<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;child: const Text('Save'),<br/>
&nbsp;&nbsp;&nbsp;&nbsp;),<br/>
&nbsp;&nbsp;]),<br/>
)""", code_style))

    story.append(PageBreak())

    # ==================== SECTION 3 ====================
    story.append(Paragraph("3. Complete Catalog of All 22 AgroManage Screens", h1_style))
    story.append(Paragraph("Detailed reference for each screen in the project, what it does, and what questions you may be asked:", body_style))

    screens_list = [
        ("01. Splash Screen", "lib/screens/splash_screen.dart",
         "Displays the brand logo (leaf emblem in green gradient container), 'AgroManage' typography, and center location pill ('Kisan Agro Center · Sahiwal'). Plays a smooth 1000ms entrance animation and holds for 4 seconds before automatically routing to the Login Screen.",
         "StatefulWidget, AnimationController, CurvedAnimation, Timer, Gradient Container.",
         "Q: 'How does it transition automatically?' -> A: 'Inside initState(), a Timer(Duration(seconds: 4)) calls the widget.onFinish callback.'"),

        ("02. Login Screen", "lib/screens/login_screen.dart",
         "Authentication portal with role selector (Shop Owner / Admin, Sales Manager, Accountant). Validates username and password against mock credentials (admin@agromanage.pk / 123456) and logs the user in.",
         "TextEditingController, Form, DropdownButtonFormField, password obscuring toggle.",
         "Q: 'How do you toggle password visibility?' -> A: 'A boolean _obscurePassword in state is toggled using setState(() => _obscurePassword = !_obscurePassword).'"),

        ("03. Main Shell (Navigation Hub)", "lib/screens/main_shell.dart",
         "The master container that wraps the entire app after login. Renders the top AppBar (shop branding, dark mode toggle, notification bell with badge), the active screen body via AnimatedSwitcher, and the persistent BottomNavigationBar.",
         "Scaffold, BottomNavigationBar, NavigationRail (responsive wide screens), AnimatedSwitcher.",
         "Q: 'How does navigation work without destroying state?' -> A: 'MainShell holds _currentRoute string. Changing the tab updates _currentRoute via setState() and renders the corresponding screen.'"),

        ("04. Executive Dashboard", "lib/screens/dashboard_screen.dart",
         "The executive home screen. Calculates and displays 4 real-time business KPIs: Today's Sales, Cash Collected, Pending Farmer Khata Dues, and Daily Expenses. Surfaces low stock and expiring chemical alerts with 1-tap reordering.",
         "MetricCard, Alert Cards, recent invoices ListView, FloatingActionButton for quick POS.",
         "Q: 'Where do these KPI numbers come from?' -> A: 'AppState computes them dynamically using getters like state.todayGrossSales and state.totalPendingBalance.'"),

        ("05. Point of Sale (POS) Billing", "lib/screens/pos_screen.dart",
         "The primary sales register. Allows selecting a farmer customer (instantly shows their existing credit balance), adding products from inventory with quantity multipliers, selecting payment mode (Cash, Bank, Khata), and creating an invoice.",
         "Dynamic cart List, DropdownButtonFormField, Form, stock validation, SnackBar feedback.",
         "Q: 'What happens when an invoice is completed?' -> A: 'AppState.recordSaleInvoice() is called. It deducts the sold quantity from each product stock and adds the unpaid amount to customer Khata.'"),

        ("06. Products Catalog", "lib/screens/products_screen.dart",
         "Interactive inventory browser. Lists all seeds, fertilizers, and pesticides with stock level badges. Supports search by product name/crop target and category chips filtering (Pesticides, Fertilizers, Seeds, Machinery).",
         "ListView.builder, TextField search filter, ChoiceChip, StatusBadge, FloatingActionButton.",
         "Q: 'How does real-time search work?' -> A: 'The search TextField onChanged listener updates _searchQuery and filters the list with .where((p) => p.name.toLowerCase().contains(query)).'"),

        ("07. Add Product Screen", "lib/screens/add_product_screen.dart",
         "Full-featured product entry form. Fields: Product name, Brand/Manufacturer, Category, Packaging Unit (Bag, Liter, Kg), Purchase Cost, Retail Price, Initial Stock, Minimum Threshold, Batch Number, and Expiry Date picker.",
         "Form, GlobalKey, TextFormField with numeric keyboards, showDatePicker dialog.",
         "Q: 'How do you pick an expiry date?' -> A: 'Using Flutter built-in showDatePicker(context: context, initialDate: ..., firstDate: ..., lastDate: ...).'"),

        ("08. Product Detail Screen", "lib/screens/product_detail_screen.dart",
         "Detailed profile for a specific chemical or seed item. Displays pricing margins, gross profit per unit, batch number, active ingredient formula, stock status indicator, and quick action to record a supplier purchase.",
         "Card, StatusBadge, custom metric chips, price calculation helpers.",
         "Q: 'How is profit margin calculated?' -> A: 'margin = (retailPrice - purchasePrice) / retailPrice * 100.'"),

        ("09. Customers Directory", "lib/screens/customers_screen.dart",
         "Directory of all farmers registered with the shop. Shows farmer name, village/address, phone number, acreage, and their outstanding Khata credit balance in colored badges.",
         "ListView.builder, search filter, Customer Card, phone dialer intent launcher.",
         "Q: 'How are customers with high debt highlighted?' -> A: 'If getCustomerBalance(id) > 50,000, StatusBadge type is red (\"Overdue\"); if 0, green (\"Clear\").'"),

        ("10. Add Customer Screen", "lib/screens/add_customer_screen.dart",
         "Farmer registration form. Captures farmer's full name, mobile number, village/tehsil address, CNIC number, land size in acres, and primary crop cultivated (Wheat, Cotton, Rice, Sugarcane).",
         "TextFormField with validation, land size numeric input, AppState.addCustomer.",
         "Q: 'How is CNIC validated?' -> A: 'Validator checks regex or length of 13 digits (without dashes) or 15 characters.'"),

        ("11. Customer Detail & Ledger", "lib/screens/customer_detail_screen.dart",
         "Comprehensive farmer Khata account ledger. Displays total lifetime purchases, cash paid to date, remaining balance, and historical list of all invoices issued to this farmer with click-through to invoice details.",
         "Nested ListView, Card, balance indicator banner, 'Record Payment' direct button.",
         "Q: 'Where is the customer invoice history retrieved?' -> A: 'AppState filters invoices using state.invoices.where((inv) => inv.customer.id == customerId).'"),

        ("12. Sales Invoices Screen", "lib/screens/invoices_screen.dart",
         "Master invoice history. Lists all issued bills with invoice number (e.g. INV-2026-001), date, farmer name, item count, total amount, and payment status (Paid, Partial, Khata Due).",
         "ListView.builder, StatusBadge, date formatting via AppTheme.formatDate.",
         "Q: 'How do you format timestamps in Flutter?' -> A: 'AppTheme.formatDate(DateTime dt) formats day, month name, and year.'"),

        ("13. Invoice Detail Screen", "lib/screens/invoice_detail_screen.dart",
         "Full receipt breakdown for a completed sale. Displays line items table (Product, Quantity, Unit Price, Total), payment breakdown (Cash paid vs Khata debt), and a 'Print / Share Receipt' action.",
         "Table / Column layout, Divider lines, receipt styling, customer summary card.",
         "Q: 'Can you show me how line totals are added?' -> A: 'inv.items.fold(0.0, (sum, item) => sum + (item.quantity * item.unitPrice)).'"),

        ("14. Record Payment Screen", "lib/screens/record_payment_screen.dart",
         "Farmer debt collection screen. Selects an invoice or farmer with pending balance, inputs the payment amount received, chooses payment channel (Cash, JazzCash, EasyPaisa, Bank), and updates the ledger.",
         "DropdownButtonFormField, numeric payment validator, AppState.recordPayment.",
         "Q: 'What happens if a farmer pays more than their dues?' -> A: 'The validator checks if amount > remainingBalance and shows an error preventing overpayment.'"),

        ("15. Installments (Khata Plans)", "lib/screens/installments_screen.dart",
         "Manages seasonal farmer credit agreements. Lists structured installment schedules tied to crop harvesting seasons, overdue payment alerts, and penalty tracking.",
         "ExpansionTile / Card, overdue date comparison, AppTheme.formatCurrency.",
         "Q: 'How are overdue installments detected?' -> A: 'plan.dueDate.isBefore(DateTime.now()) && plan.paidAmount < plan.dueAmount.'"),

        ("16. Agrochemical Suppliers", "lib/screens/suppliers_screen.dart",
         "Directory of certified seed, fertilizer, and pesticide manufacturers (e.g. Engro Fertilizers, Bayer CropScience, FMC, Syngenta). Shows sales representative contacts and total stock supplied.",
         "ListTile, CircleAvatar branding, phone call action.",
         "Q: 'What model represents a vendor?' -> A: 'The Supplier model with fields: id, name, representative, phone, city, productsSupplied.'"),

        ("17. Purchases (Stock In)", "lib/screens/purchases_screen.dart",
         "Log of wholesale inventory restocks. Tracks purchase order numbers (PO-101), supplier name, shipment arrival date, and total wholesale invoice cost.",
         "ListView.builder, StatusBadge, wholesale invoice summary.",
         "Q: 'How does purchasing affect inventory?' -> A: 'Recording a purchase increases the stock count of the corresponding Product in AppState.'"),

        ("18. New Purchase Order", "lib/screens/new_purchase_screen.dart",
         "Restock entry form. Selects a supplier, chooses the product received, inputs wholesale quantity and bulk purchase price, and updates stock counts automatically.",
         "DropdownButtonFormField, Form, numeric multipliers, AppState.recordPurchaseOrder.",
         "Q: 'How is new stock added to existing stock?' -> A: 'AppState finds the product by id and runs product.stock += newQuantity; notifyListeners().'"),

        ("19. Shop Expenses Screen", "lib/screens/expenses_screen.dart",
         "Daily operational cost manager. Logs shop expenses categorized by Utility Bills (Tube-well, WAPDA), Generator Diesel, Store Rent, Staff Daily Wages, and Freight/Transport.",
         "showDialog popup entry, category dropdown, expense list, total expenses KPI.",
         "Q: 'How do you create a popup dialog in Flutter?' -> A: 'Using showDialog(context: context, builder: (context) => AlertDialog(...)).'"),

        ("20. Financial Reports Screen", "lib/screens/reports_screen.dart",
         "Business intelligence & summaries. Shows Net Profit = (Gross Revenue - Cost of Goods - Shop Expenses), cash vs credit breakdown percentages, and top 5 best-selling chemicals.",
         "Summary cards, percentage progress bars (LinearProgressIndicator), mathematical calculations.",
         "Q: 'How is Net Profit calculated in the code?' -> A: 'final netProfit = totalSales - totalCostOfGoods - totalExpenses.'"),

        ("21. Alerts & Notifications", "lib/screens/notifications_screen.dart",
         "Safety and inventory alert center. Categorizes urgent alerts into: 1) Low Stock warnings, 2) Agrochemicals expiring within 90 days, and 3) Overdue farmer installment accounts.",
         "Card, StatusBadge, quick action buttons ('Reorder Stock', 'Call Farmer').",
         "Q: 'How do you filter expiring chemicals?' -> A: 'state.products.where((p) => p.expiryDate.difference(DateTime.now()).inDays <= 90).'"),

        ("22. Settings & Preferences", "lib/screens/settings_screen.dart",
         "App settings screen. Allows toggling Dark Mode / Light Mode, changing shop business details (Shop Name, License No, Phone), exporting data, and user logout.",
         "SwitchListTile, AppState.toggleThemeMode(), logout callback.",
         "Q: 'How does Dark Mode switch instantly across all screens?' -> A: 'AppState calls notifyListeners(), causing AnimatedBuilder in main.dart to rebuild with AppTheme.darkTheme.'"),
    ]

    for title, filepath, purpose, widgets, viva in screens_list:
        card_content = [
            [Paragraph(f"<b>{title}</b>", h2_style), Paragraph(f"<code>{filepath}</code>", code_style)],
            [Paragraph("<b>Purpose & Logic:</b> " + purpose, body_style), ""],
            [Paragraph("<b>Key Widgets Used:</b> " + widgets, body_style), ""],
            [Paragraph("<b>Viva Live Coding Tip:</b> " + viva, box_style), ""],
        ]
        t = Table(card_content, colWidths=[360, 144])
        t.setStyle(TableStyle([
            ('SPAN', (0, 1), (1, 1)),
            ('SPAN', (0, 2), (1, 2)),
            ('SPAN', (0, 3), (1, 3)),
            ('BACKGROUND', (0, 0), (-1, 0), c_light_bg),
            ('BACKGROUND', (0, 3), (-1, 3), colors.HexColor("#FFFDE7")),
            ('BOX', (0, 0), (-1, -1), 0.8, c_border),
            ('INNERGRID', (0, 0), (-1, -1), 0.4, colors.HexColor("#EEEEEE")),
            ('TOPPADDING', (0, 0), (-1, -1), 3),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
            ('LEFTPADDING', (0, 0), (-1, -1), 6),
            ('RIGHTPADDING', (0, 0), (-1, -1), 6),
        ]))
        story.append(t)
        story.append(Spacer(1, 5))

    story.append(PageBreak())

    # ==================== SECTION 4 ====================
    story.append(Paragraph("4. Top 15 Viva Questions & Direct Answers", h1_style))
    story.append(Paragraph("Read these answers carefully so you can speak confidently during evaluation:", body_style))

    qa_list = [
        ("1. What is the difference between Hot Reload and Hot Restart in Flutter?",
         "Hot Reload (r) injects updated source code files into the running Dart VM without destroying the application state (takes ~1 sec). Hot Restart (R) destroys the current state and restarts the app from main() (takes ~3 sec). Full rebuild is required when adding native assets or plugins."),

        ("2. What is the purpose of BuildContext in Flutter?",
         "BuildContext is a handle to the location of a widget in the Widget Tree. It is used by methods like Theme.of(context), Navigator.of(context), and MediaQuery.of(context) to look up configuration up the tree."),

        ("3. Why do we use setState() in StatefulWidget?",
         "setState() notifies the Flutter framework that the internal state of the widget has changed. This schedules a call to the build() method, causing the UI to redraw with the new values. Changing a variable without setState() will NOT update the screen."),

        ("4. How does State Management work in this AgroManage project?",
         "We use the ChangeNotifier pattern with AppState. AppState holds lists of products, customers, and invoices. When a method like recordSaleInvoice() is called, it updates the in-memory data and executes notifyListeners(). In main.dart, AnimatedBuilder listens to AppState and automatically rebuilds."),

        ("5. What is the difference between Expanded and Flexible in a Row/Column?",
         "Both are used inside Flex containers (Row/Column). Expanded forces its child to occupy all remaining available space (equivalent to Flexible with fit: FlexFit.tight). Flexible with FlexFit.loose allows the child to only take as much space as it needs up to the maximum available."),

        ("6. What is a GlobalKey<FormState> used for?",
         "A GlobalKey uniquely identifies a Form widget and gives access to its FormState. It allows calling _formKey.currentState!.validate() to trigger all validator functions across the form, and .save() to save values."),

        ("7. Why must TextEditingControllers be disposed?",
         "Controllers allocate memory and listen to text input streams. If not disposed via controller.dispose() inside the State.dispose() lifecycle method, they cause memory leaks when the screen is popped off the navigation stack."),

        ("8. How is the 4-second Splash Screen implemented?",
         "SplashScreen is a StatefulWidget. Inside initState(), an AnimationController plays an entrance scale/fade animation, and a Timer(const Duration(seconds: 4)) executes a callback onFinish() that flips _showSplash = false in main.dart, seamlessly transitioning to LoginScreen."),

        ("9. What is ListView.builder and why is it preferred over a simple ListView?",
         "ListView.builder creates list items lazily on demand only as they scroll into view on screen. A standard ListView([children]) builds all children at once, which consumes excessive RAM if there are 100+ products or customers."),

        ("10. What is pubspec.yaml and what is it used for?",
         "pubspec.yaml is the project configuration file. It defines the application metadata (name, description, version), Dart SDK constraints, third-party packages (dependencies), development tools (flutter_lints), and local asset paths (images, fonts)."),

        ("11. How do you pass data from one screen to another screen?",
         "By passing arguments into the constructor of the destination screen. For example, when opening CustomerDetailScreen(customer: selectedCustomer), the selected customer object is received and stored in final Customer customer."),

        ("12. How does the POS screen prevent selling products that are out of stock?",
         "In pos_screen.dart, before adding an item or confirming an invoice, the code checks if (cartQuantity > product.stock). If true, it displays an error SnackBar ('Insufficient stock for this product') and stops execution."),

        ("13. What is an AlertDialog and how is it shown?",
         "An AlertDialog is a modal popup. It is invoked via showDialog(context: context, builder: (context) => AlertDialog(title: Text(...), content: Text(...), actions: [...])). It is dismissed using Navigator.pop(context)."),

        ("14. How does Dark Mode work in your application?",
         "AppTheme defines both lightTheme and darkTheme. AppState contains a ThemeMode property (_themeMode). When the toggle is tapped, it flips between ThemeMode.light and ThemeMode.dark, calls notifyListeners(), and MaterialApp automatically swaps palettes."),

        ("15. Why does the examiner prohibit AI tools and require basic code completion?",
         "To test independent problem-solving skills, understanding of widget structures, and fundamental Dart syntax without relying on automated generation. Only Ctrl + Space basic autocomplete in Android Studio is permitted.")
    ]

    for q, a in qa_list:
        qa_data = [
            [Paragraph(f"<b>{q}</b>", h2_style)],
            [Paragraph(f"<b>Answer:</b> {a}", body_style)],
        ]
        t = Table(qa_data, colWidths=[504])
        t.setStyle(TableStyle([
            ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#E8F5E9")),
            ('BOX', (0,0), (-1,-1), 0.5, c_border),
            ('TOPPADDING', (0,0), (-1,-1), 3),
            ('BOTTOMPADDING', (0,0), (-1,-1), 3),
            ('LEFTPADDING', (0,0), (-1,-1), 6),
            ('RIGHTPADDING', (0,0), (-1,-1), 6),
        ]))
        story.append(t)
        story.append(Spacer(1, 4))

    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"PDF Successfully generated: {filename}")

if __name__ == '__main__':
    build_pdf()
