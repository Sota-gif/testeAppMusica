import 'package:flutter/material.dart';
import '../models/track.dart';
import '../services/api_service.dart';
import '../services/audio_player_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final AudioPlayerService _audioService = AudioPlayerService();
  final TextEditingController _searchController = TextEditingController();

  List<Track> _searchResults = [];
  Track? _currentTrack;
  bool _isLoading = false;
  int _selectedCategoryIndex = 0;
  int _bottomNavIndex = 0;

  final List<String> _categories = [
    'Tudo',
    'Playlists',
    'Offline (Baixadas)',
    'Favoritas'
  ];

  void _onSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    final track = await _apiService.searchAndFetchTrack(query);

    setState(() {
      _isLoading = false;
      if (track != null) {
        _searchResults = [track];
      } else {
        _searchResults = [];
      }
    });
  }

  // INTUITIVO: Exibe o Menu Inferior com opções ao clicar nos três pontinhos (...)
  void _showTrackOptions(BuildContext context, Track track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    track.coverUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.white),
                  ),
                ),
                title: Text(track.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(track.artist, style: const TextStyle(color: Colors.grey)),
              ),
              const Divider(color: Colors.white12),
              ListTile(
                leading: const Icon(Icons.playlist_add, color: Colors.white),
                title: const Text('Salvar em Playlist Online', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showToast('Adicionado à playlist!');
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text('Compartilhar Músicas', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // INTUITIVO: Notificação rápida na tela
  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.deepPurpleAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Colors.grey[950];
    final cardColor = Colors.grey[900];
    final primaryAccent = Colors.deepPurpleAccent;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabeçalho
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Músicas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // 2. Barra de Busca
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar música ou artista...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onSubmitted: (_) => _onSearch(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.tune, color: primaryAccent),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // 3. Pílulas / Categorias
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(_categories[index]),
                      selected: isSelected,
                      selectedColor: primaryAccent,
                      backgroundColor: cardColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[400],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // 4. Lista de Músicas
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.music_note, size: 64, color: Colors.grey[800]),
                            const SizedBox(height: 12),
                            Text(
                              'Digite algo na busca para começar',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final track = _searchResults[index];
                          final isPlayingThis = _currentTrack?.id == track.id;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: isPlayingThis
                                  ? Border.all(color: primaryAccent, width: 1.5)
                                  : null,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  track.coverUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[800],
                                    width: 50,
                                    height: 50,
                                    child: const Icon(Icons.music_note, color: Colors.white),
                                  ),
                                ),
                              ),
                              title: Text(
                                track.title,
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                track.artist,
                                style: TextStyle(color: Colors.grey[400]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Botão Download com Toast
                                  IconButton(
                                    icon: const Icon(Icons.download_rounded, color: Colors.white70),
                                    onPressed: () {
                                      _showToast('Iniciando download...');
                                    },
                                  ),
                                  // Botão Play
                                  IconButton(
                                    icon: Icon(
                                      isPlayingThis
                                          ? Icons.pause_circle_fill
                                          : Icons.play_circle_fill,
                                      color: primaryAccent,
                                      size: 38,
                                    ),
                                    onPressed: () {
                                      setState(() => _currentTrack = track);
                                      _audioService.playTrack(
                                        pathOrUrl: track.streamUrl,
                                        isLocal: false,
                                      );
                                    },
                                  ),
                                  // Botão Mais Opções (...)
                                  IconButton(
                                    icon: const Icon(Icons.more_vert, color: Colors.white54),
                                    onPressed: () => _showTrackOptions(context, track),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

            // 5. Mini Player Flutuante
            if (_currentTrack != null)
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryAccent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryAccent.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _currentTrack!.coverUrl,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentTrack!.title,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _currentTrack!.artist,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.pause, color: Colors.white),
                      onPressed: () => _audioService.pause(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      onPressed: () => _audioService.resume(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),

      // 6. Barra de Navegação Inferior
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cardColor,
        currentIndex: _bottomNavIndex,
        selectedItemColor: primaryAccent,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_special),
            label: 'Offline',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}