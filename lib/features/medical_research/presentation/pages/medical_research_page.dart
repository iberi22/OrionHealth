import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../application/medical_research_cubit.dart';
import '../widgets/research_result_card.dart';
import '../widgets/interaction_checker_widget.dart';

class MedicalResearchPage extends StatefulWidget {
  const MedicalResearchPage({super.key});

  @override
  State<MedicalResearchPage> createState() => _MedicalResearchPageState();
}

class _MedicalResearchPageState extends State<MedicalResearchPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _icd10Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _icd10Controller.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<MedicalResearchCubit>().performResearch(query);
    }
  }

  void _onIcd10Lookup() {
    final query = _icd10Controller.text.trim();
    if (query.isNotEmpty) {
      context.read<MedicalResearchCubit>().lookupIcd10(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MedicalResearchCubit>(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'INVESTIGACIÓN MÉDICA',
            style: TextStyle(
              color: CyberTheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: CyberTheme.secondary,
            labelColor: CyberTheme.secondary,
            unselectedLabelColor: Colors.white54,
            isScrollable: true,
            tabs: const [
              Tab(text: 'EVIDENCIA', icon: Icon(Icons.science)),
              Tab(text: 'INTERACCIONES', icon: Icon(Icons.medication_liquid)),
              Tab(text: 'ICD-10', icon: Icon(Icons.tag)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildEvidenceTab(),
            _buildInteractionsTab(),
            _buildIcd10Tab(),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceTab() {
    return BlocBuilder<MedicalResearchCubit, MedicalResearchState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BUSCAR EN BASES DE DATOS MÉDICAS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Ej: Tratamiento para Diabetes Tipo 2...',
                              hintStyle: const TextStyle(color: Colors.white30),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.search, color: Colors.white54),
                            ),
                            onSubmitted: (_) => _onSearch(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _onSearch,
                          icon: const Icon(Icons.send),
                          style: IconButton.styleFrom(
                            backgroundColor: CyberTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fuentes: PubMed, FDA, WHO, ClinicalTrials.gov',
                      style: TextStyle(color: Colors.white30, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            if (state.status == MedicalResearchStatus.loading &&
                state.loadingMessage!.contains('Buscando evidencia'))
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: CyberTheme.primary),
                ),
              )
            else if (state.status == MedicalResearchStatus.error && state.errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              )
            else if (state.results.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ResearchResultCard(result: state.results[index]),
                    ),
                    childCount: state.results.length,
                  ),
                ),
              )
            else if (state.status == MedicalResearchStatus.success && state.results.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No se encontraron resultados para tu búsqueda.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.white10),
                      SizedBox(height: 16),
                      Text(
                        'Ingresa una consulta para comenzar la investigación.',
                        style: TextStyle(color: Colors.white24),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInteractionsTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: InteractionCheckerWidget(),
    );
  }

  Widget _buildIcd10Tab() {
    return BlocBuilder<MedicalResearchCubit, MedicalResearchState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BÚSQUEDA DE CÓDIGOS ICD-10',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _icd10Controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ej: Hipertensión, Diabetes...',
                        hintStyle: const TextStyle(color: Colors.white30),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.tag, color: Colors.white54),
                      ),
                      onSubmitted: (_) => _onIcd10Lookup(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _onIcd10Lookup,
                    icon: const Icon(Icons.search),
                    style: IconButton.styleFrom(
                      backgroundColor: CyberTheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (state.status == MedicalResearchStatus.loading &&
                  state.loadingMessage!.contains('ICD-10'))
                const Center(
                  child: CircularProgressIndicator(color: CyberTheme.secondary),
                )
              else if (state.icd10Result != null)
                GlassmorphicCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: CyberTheme.secondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: CyberTheme.secondary),
                              ),
                              child: Text(
                                state.icd10Result!.code,
                                style: const TextStyle(
                                  color: CyberTheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.icd10Result!.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Categoría: ${state.icd10Result!.category}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        if (state.icd10Result!.synonyms != null && state.icd10Result!.synonyms!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Sinónimos:',
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.icd10Result!.synonyms!.join(', '),
                            style: const TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else if (state.status == MedicalResearchStatus.success && state.icd10Result == null)
                const Center(
                  child: Text(
                    'No se encontró ningún código para esa descripción.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

