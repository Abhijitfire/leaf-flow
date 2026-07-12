import '../../features/sections/domain/models/section_model.dart';

class MockData {
  static const List<SectionModel> sections = [
    SectionModel(
      id: 'S1',
      name: 'Section 1 - Bhalu Khop',
      areaHectares: 12.5,
      clone: 'TV1',
      plantYear: 1995,
      status: 'Active',
      lastPluckedDaysAgo: 7,
      estimatedYieldKg: 450,
    ),
    SectionModel(
      id: 'S2',
      name: 'Section 2 - Baseri',
      areaHectares: 8.2,
      clone: 'TV1',
      plantYear: 1998,
      status: 'Resting',
      lastPluckedDaysAgo: 1,
      estimatedYieldKg: 0,
    ),
    SectionModel(
      id: 'S7',
      name: 'Section 7 - North Slope',
      areaHectares: 15.0,
      clone: 'P316',
      plantYear: 2005,
      status: 'Active',
      lastPluckedDaysAgo: 9,
      estimatedYieldKg: 620,
    ),
    SectionModel(
      id: 'S9',
      name: 'Section 9 - Upper Ridge',
      areaHectares: 10.5,
      clone: 'TV1',
      plantYear: 2010,
      status: 'Pruning',
      lastPluckedDaysAgo: 45,
      estimatedYieldKg: 0,
    ),
    SectionModel(
      id: 'S14',
      name: 'Section 14 - Valley',
      areaHectares: 20.0,
      clone: 'B157',
      plantYear: 2018,
      status: 'Active',
      lastPluckedDaysAgo: 6,
      estimatedYieldKg: 850,
    ),
  ];
}
