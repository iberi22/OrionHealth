import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/eps_connection_cubit.dart';
import '../../application/bloc/eps_connection_state.dart';
import '../widgets/eps_connection_status_card.dart';
import '../widgets/eps_provider_card.dart';
import '../widgets/eps_qr_scanner_page.dart';
import '../pages/eps_patient_portal_screen.dart';
import '../../domain/entities/eps_connection.dart';
import '../../domain/entities/eps_providers_catalog.dart';
import '../../domain/entities/eps_provider.dart';
import '../../../onboarding/domain/entities/user_profile.dart';

import '../../../../core/widgets/page_header.dart';
import '../../../../core/theme/app_colors.dart';

class EpsConnectionPage extends StatefulWidget {
  final EpsConnectionCubit? cubit;

  const EpsConnectionPage({super.key, this.cubit});

  @override
  State<EpsConnectionPage> createState() => _EpsConnectionPageState();
}

class _EpsConnectionPageState extends State<EpsConnectionPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _regimeFilter;
  bool _showCatalog = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              PageHeader(
                title: '📋 EPS Colombia',
                subtitle: '${EpsProvidersCatalog.count} EPS disponibles',
                showBackButton: true,
                trailing: IconButton(
                  icon: const Icon(Icons.qr_code_scanner,
                      color: AppColors.primary),
                  onPressed: () => _openQrScanner(context),
                ),
              ),
              _buildSearchBar(),
              _buildRegimeFilter(),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar EPS por nombre...',
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (q) => setState(() => _searchQuery = q.trim()),
      ),
    );
  }

  Widget _buildRegimeFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _filterChip('Todas', null),
          const SizedBox(width: 8),
          _filterChip('Ambos regímenes', 'ambos'),
          const SizedBox(width: 8),
          _filterChip('Contributivo', 'contributivo'),
          const SizedBox(width: 8),
          _filterChip('Subsidiado', 'subsidiado'),
          const SizedBox(width: 8),
          _filterChip('Indígena (EPSI)', 'especial'),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? regime) {
    final selected = _regimeFilter == regime;
    return GestureDetector(
      onTap: () => setState(() => _regimeFilter = regime),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : Colors.white70,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.cubit != null) {
      return BlocProvider<EpsConnectionCubit>.value(
        value: widget.cubit!,
        child: _buildBlocBody(context),
      );
    }

    try {
      context.read<EpsConnectionCubit>();
      return _buildBlocBody(context);
    } catch (_) {
      return _buildStandaloneCatalog();
    }
  }

  /// UI standalone cuando no hay Cubit disponible.
  Widget _buildStandaloneCatalog() {
    final filtered = _filteredProviders();
    if (filtered.isEmpty) {
      return const Center(
        child: Text('No se encontraron EPS',
            style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSectionHeader(
              '${_regimeFilter ?? 'Todas las'} EPS (${filtered.length})');
        }
        final provider = filtered[index - 1];
        return EpsProviderCard(provider: provider);
      },
    );
  }

  Widget _buildBlocBody(BuildContext context) {
    return BlocConsumer<EpsConnectionCubit, EpsConnectionState>(
      listener: (context, state) {
        if (state is EpsConnectionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      builder: (context, state) {
        switch (state) {
          case EpsConnectionCatalog(:final availableProviders,
                :final connections,
                :final connectedProviderIds):
            return _buildCatalogView(
              availableProviders,
              connections,
              connectedProviderIds,
              context,
            );

          case EpsConnectionConnecting(:final provider):
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Conectando con ${provider.name}...',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Esto puede tomar unos segundos',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            );

          case EpsConnectionLoading():
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );

          case EpsConnectionLoaded(:final connections):
            return _buildConnectionsOnly(connections, context);

          case EpsConnectionError():
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    (state as EpsConnectionError).message,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<EpsConnectionCubit>().loadCatalog(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );

          case EpsConnectionPortalConnected():
            // Portal extraction complete — reload catalog to show state
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<EpsConnectionCubit>().loadCatalog();
            });
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
        }
      },
    );
  }

  Widget _buildCatalogView(
    List<EPSProvider> providers,
    List<EPSConnection> connections,
    List<String> connectedIds,
    BuildContext context,
  ) {
    final filtered = _filterProviderList(providers);

    // Provider conectados → EPSProviderCard solo para no conectados
    final conectarProviders = filtered
        .where((p) => !connectedIds.contains(p.id))
        .toList();

    // Providers ya conectados
    final conectedProviders = filtered
        .where((p) => connectedIds.contains(p.id))
        .toList();

    if (connections.isEmpty && conectarProviders.isEmpty) {
      return _buildEmptySearch();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _itemCount(connections, conectedProviders, conectarProviders),
      itemBuilder: (context, index) {
        int i = 0;

        // Sección: Conectados
        if (connections.isNotEmpty && i == index) {
          return _buildSectionHeader(
              '✅ Conectadas (${connections.length})');
        }
        i++;

        for (final conn in connections) {
          if (i == index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EpsConnectionStatusCard(
                connection: conn,
                onDisconnect: () =>
                    context.read<EpsConnectionCubit>().disconnect(conn.provider.id),
              ),
            );
          }
          i++;
        }

        // Sección: Disponibles para conectar
        if (conectarProviders.isNotEmpty && i == index) {
          return _buildSectionHeader(
              '🔗 ${_regimeFilter ?? 'EPS'} Disponibles (${conectarProviders.length})');
        }
        i++;

        for (final provider in conectarProviders) {
          if (i == index) {
            return EpsProviderCard(
              provider: provider,
              onConnect: () => _handleProviderConnect(context, provider),
            );
          }
          i++;
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildConnectionsOnly(
      List<EPSConnection> connections, BuildContext context) {
    if (connections.isEmpty) {
      return const Center(
        child: Text('No hay conexiones activas',
            style: TextStyle(color: Colors.white70)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: connections.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildSectionHeader('✅ Conectadas (${connections.length})');
        final conn = connections[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EpsConnectionStatusCard(
            connection: conn,
            onDisconnect: () =>
                context.read<EpsConnectionCubit>().disconnect(conn.provider.id),
          ),
        );
      },
    );
  }

  int _itemCount(
    List<EPSConnection> connections,
    List<EPSProvider> conectedProviders,
    List<EPSProvider> conectarProviders,
  ) {
    int count = 0;
    if (connections.isNotEmpty) count += 1 + connections.length;
    if (conectarProviders.isNotEmpty) count += 1 + conectarProviders.length;
    return count;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text(
            'No se encontraron EPS',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'con el filtro "${_searchQuery.isNotEmpty ? _searchQuery : _regimeFilter ?? 'todas'}"',
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─── Filtrado ────────────────────────────────────────────

  List<EPSProvider> _filteredProviders() {
    var list = EpsProvidersCatalog.activeProviders;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.id.toLowerCase().contains(q);
      }).toList();
    }

    if (_regimeFilter != null && _regimeFilter != 'especial') {
      list = list
          .where((p) => _regimeMatches(p.id, _regimeFilter!))
          .toList();
    } else if (_regimeFilter == 'especial') {
      list = list.where((p) => p.id.startsWith('EPSI')).toList();
    }

    return list;
  }

  List<EPSProvider> _filterProviderList(List<EPSProvider> providers) {
    if (_searchQuery.isEmpty && _regimeFilter == null) return providers;

    return providers.where((p) {
      bool matches = true;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        matches = p.name.toLowerCase().contains(q) ||
            p.id.toLowerCase().contains(q);
      }
      if (matches && _regimeFilter != null) {
        if (_regimeFilter == 'especial') {
          matches = p.id.startsWith('EPSI');
        } else {
          matches = _regimeMatches(p.id, _regimeFilter!);
        }
      }
      return matches;
    }).toList();
  }

  bool _regimeMatches(String id, String regime) {
    // Usamos el catálogo para determinar régimen por ID
    if (regime == 'ambos') {
      return EpsProvidersCatalog.ambosRegimenes.any((p) => p.id == id);
    }
    if (regime == 'contributivo') {
      return EpsProvidersCatalog.soloContributivo.any((p) => p.id == id) ||
          EpsProvidersCatalog.ambosRegimenes.any((p) => p.id == id);
    }
    if (regime == 'subsidiado') {
      return EpsProvidersCatalog.soloSubsidiado.any((p) => p.id == id) ||
          EpsProvidersCatalog.ambosRegimenes.any((p) => p.id == id);
    }
    return true;
  }

  // ─── QR ─────────────────────────────────────────────────

  Future<void> _openQrScanner(BuildContext context) async {
    try {
      final result = await Navigator.push<EPSProviderScanResult>(
        context,
        MaterialPageRoute(builder: (_) => const EpsQrScannerPage()),
      );
      if (result != null && context.mounted) {
        _handleScanResult(context, result);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir el escáner: $e')),
        );
      }
    }
  }

  void _handleScanResult(BuildContext context, EPSProviderScanResult result) {
    if (result.providerId != null) {
      final provider = EpsProvidersCatalog.byId(result.providerId!);
      if (provider != null) {
        try {
          context.read<EpsConnectionCubit>().connect(provider);
          return;
        } catch (_) {}
      }
    }

    if (result.discoveryUrl != null) {
      final provider = EPSProvider(
        id: result.providerId ??
            'scanned-${DateTime.now().millisecondsSinceEpoch}',
        name: result.providerId ?? 'EPS Escaneada',
        discoveryUrl: result.discoveryUrl!,
        clientId: 'orionhealth',
        redirectUrl: 'orionhealth://callback',
        scopes: const [
          'openid',
          'fhirUser',
          'offline_access',
          'patient/Patient.read',
          'patient/Observation.read'
        ],
      );
      try {
        context.read<EpsConnectionCubit>().connect(provider);
        return;
      } catch (_) {}
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Código QR no reconocido como EPS válida')),
    );
  }

  // ─── Patient Portal Extraction ─────────────────────────────

  /// Routes the connection attempt based on provider capabilities.
  ///
  /// Providers with SMART on FHIR configured (has a non-empty [clientId]
  /// and [redirectUrl]) use the standard OAuth2 Authorization Code + PKCE flow.
  ///
  /// Providers without SMART on FHIR use the Patient Portal Extractor,
  /// which opens the EPS web portal in an embedded WebView for the patient
  /// to authenticate with their existing credentials, then extracts clinical
  /// data via on-device RPA (HTTP interception + JS injection).
  Future<void> _handleProviderConnect(
      BuildContext context, EPSProvider provider) async {
    final hasSmartOnFhir =
        provider.clientId.isNotEmpty && provider.redirectUrl.isNotEmpty;

    if (hasSmartOnFhir) {
      // Standard SMART on FHIR OAuth2 flow
      try {
        context.read<EpsConnectionCubit>().connect(provider);
      } catch (_) {}
      return;
    }

    // Patient Portal Extraction flow (on-device RPA)
    try {
      final patientData = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (_) => EpsPatientPortalScreen(provider: provider),
        ),
      );

      if (patientData != null && patientData.isNotEmpty && context.mounted) {
        // Show extraction results before proceeding
        _showExtractionResults(context, provider, patientData);
      }
    } catch (_) {}
  }

  /// Shows a dialog with all extracted data fields from the EPS portal.
  void _showExtractionResults(
    BuildContext context,
    EPSProvider provider,
    Map<String, dynamic> data,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ExtractionResultsSheet(
        provider: provider,
        data: data,
        onContinue: () {
          Navigator.of(ctx).pop();
          try {
            context.read<EpsConnectionCubit>().markPortalConnected(
                  provider: provider,
                  patientId: data['documentId'] as String?,
                );
          } catch (_) {}
        },
      ),
    );
  }
}

/// Bottom sheet that displays extracted EPS data with field-level details.
class _ExtractionResultsSheet extends StatelessWidget {
  final EPSProvider provider;
  final Map<String, dynamic> data;
  final VoidCallback onContinue;

  const _ExtractionResultsSheet({
    required this.provider,
    required this.data,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final scalarFields = _buildScalarFields();
    final listFields = _buildListFields();
    final metaFields = _buildMetaFields();

    // Count extracted vs total fields
    int foundCount = 0;
    final scalarKeys = ['name', 'documentId', 'birthDate', 'sex', 'phone', 'email', 'address', 'bloodType', 'affiliationType', 'affiliationDate'];
    final listKeys = ['conditions', 'medications', 'allergies', 'vaccines', 'appointments'];
    for (final k in [...scalarKeys, ...listKeys]) {
      final v = data[k];
      if (v != null && (v is! String || v.isNotEmpty) && (v is! List || v.isNotEmpty)) foundCount++;
    }
    final totalFields = scalarKeys.length + listKeys.length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✅ Datos Extraídos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${provider.name} — $foundCount de $totalFields campos encontrados',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          // Content
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shrinkWrap: true,
              children: [
                if (scalarFields.isNotEmpty) ...[
                  _buildSectionTitle('📋 Datos Personales'),
                  const SizedBox(height: 8),
                  ...scalarFields,
                  const SizedBox(height: 16),
                ],
                if (listFields.isNotEmpty) ...[
                  _buildSectionTitle('🏥 Datos Clínicos'),
                  const SizedBox(height: 8),
                  ...listFields,
                  const SizedBox(height: 16),
                ],
                if (metaFields.isNotEmpty) ...[
                  _buildSectionTitle('🔧 Metadata'),
                  const SizedBox(height: 8),
                  ...metaFields,
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          // Continue button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.arrow_forward, size: 20),
                label: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  List<Widget> _buildScalarFields() {
    final fields = <String, String>{
      'Nombre': 'name',
      'Documento': 'documentId',
      'Fecha Nacimiento': 'birthDate',
      'Sexo': 'sex',
      'Teléfono': 'phone',
      'Email': 'email',
      'Dirección': 'address',
      'Tipo Sangre': 'bloodType',
      'Tipo Afiliación': 'affiliationType',
      'Fecha Afiliación': 'affiliationDate',
    };

    return fields.entries.map((e) {
      final value = data[e.value];
      final hasData = value != null && value.toString().isNotEmpty;
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              hasData ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: hasData ? Colors.green : Colors.white24,
            ),
            const SizedBox(width: 10),
            Text(
              '${e.key}: ',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
            Expanded(
              child: Text(
                hasData ? value.toString() : '(no encontrado)',
                style: TextStyle(
                  color: hasData ? Colors.white : Colors.white24,
                  fontSize: 13,
                  fontWeight: hasData ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildListFields() {
    final listFields = <String, String>{
      'Condiciones': 'conditions',
      'Medicamentos': 'medications',
      'Alergias': 'allergies',
      'Vacunas': 'vaccines',
      'Citas': 'appointments',
    };

    final widgets = <Widget>[];
    for (final entry in listFields.entries) {
      final value = data[entry.value];
      final hasData = value is List && value.isNotEmpty;
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                hasData ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 16,
                color: hasData ? Colors.green : Colors.white24,
              ),
              const SizedBox(width: 10),
              Text(
                '${entry.key}: ',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
              Expanded(
                child: Text(
                  hasData ? '${value.length} elementos' : '(vacío)',
                  style: TextStyle(
                    color: hasData ? Colors.white : Colors.white24,
                    fontSize: 13,
                    fontWeight: hasData ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _buildMetaFields() {
    final meta = <String, String>{};
    if (data.containsKey('epsProviderName')) {
      meta['EPS'] = data['epsProviderName'].toString();
    }
    if (data.containsKey('endpointsDiscovered')) {
      meta['APIs descubiertas'] = '${data['endpointsDiscovered']}';
    }
    if (data.containsKey('pageText')) {
      final pageText = data['pageText'].toString();
      if (pageText.isNotEmpty) {
        meta['Texto página'] = '${pageText.length} caracteres capturados';
      }
    }

    return meta.entries.map((e) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 14, color: Colors.white38),
            const SizedBox(width: 10),
            Text(
              '${e.key}: ',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            Text(
              e.value,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      );
    }).toList();
  }
}
