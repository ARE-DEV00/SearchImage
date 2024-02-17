import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_image/domain/entity/image_info_entitiy.dart';
import 'package:search_image/domain/entity/search_image_list_meta_entity.dart';
import 'package:search_image/domain/usecase/search_image_use_case.dart';
import 'package:search_image/presentation/ui/state/search_image_state.dart';

class SearchImageViewModel extends StateNotifier<SearchImageState> {
  SearchImageViewModel() : super(SearchImageState());

  final _searchImageUseCase = SearchImageUseCase();
  List<ImageInfoEntity> _searchImageEntityList = [];
  SearchImageResultMetaEntity? _searchResultMeta;
  int _page = 1;
  String _query = '';

  Future<void> searchImages(String query) async {
    reset();

    if (query.isEmpty) {
      state = SearchImageState(imageInfoEntityList: []);
      return;
    }

    _query = query;
    final searchImageListEntity = await _searchImageUseCase.getSearchImageList(query, _page++);
    _searchResultMeta = searchImageListEntity.searchImageResultMetaEntity;
    _searchImageEntityList = searchImageListEntity.imageInfoEntityList;
    state = SearchImageState(imageInfoEntityList: _searchImageEntityList);
  }

  Future<void> loadMoreSearchImages() async {
    log('#### _page:$_page');

    // 검색결과가 더이상 없을 경우
    if(_searchResultMeta?.isEnd == true) {
      return;
    }

    // 검색어가 없는 경우
    if (_query.isEmpty) {
      state = SearchImageState(imageInfoEntityList: []);
      return;
    }

    final searchImageListEntity = await _searchImageUseCase.getSearchImageList(_query, _page++);
    _searchResultMeta = searchImageListEntity.searchImageResultMetaEntity;
    _searchImageEntityList += searchImageListEntity.imageInfoEntityList;
    state = SearchImageState(imageInfoEntityList: _searchImageEntityList);
  }

  void reset() {
    _page = 1;
    _query = '';
    _searchImageEntityList = [];
    _searchResultMeta = null;
  }
}
