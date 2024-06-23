// Define geometry
// var geometry = ee.Geometry.Polygon([
//   [[99.61697177434627,1.23523655409474],
//   [100.80898837590877,1.23523655409474],
//   [100.80898837590877,2.421134824263259],
//   [99.61697177434627,2.421134824263259],
//   [99.61697177434627,1.23523655409474]]
// ]);


// Tree cover in year 2000 ==========
// Load Tree Cover
var dataset = ee.Image('UMD/hansen/global_forest_change_2022_v1_10');

// Select tree cover 2000
var cover2000 = dataset.select('treecover2000');

// Clip to the output image to the geometry boundary.
var cover2000 = cover2000.clip(geometry);

var treeCoverVisParam = {
  min: 0,
  max: 100,
  palette: ['black', 'green']
};
Map.addLayer(cover2000, treeCoverVisParam, 'tree cover in year 2000');


// Loss year =======================
// Select loss year
var lossyear = dataset.select('lossyear');

// Clip to the output image to the geometry boundary.
var lossyear = lossyear.clip(geometry);

var treeLossVisParam = {
  min: 0,
  max: 22,
  palette: ['yellow', 'red']
};
Map.addLayer(lossyear, treeLossVisParam, 'tree loss year');


// Carbon density =======================
// Load data
var carbon = ee.Image('WCMC/biomass_carbon_density/v1_0/2010');

// Clip to the output image to the geometry boundary.
var carbon = carbon.clip(geometry);

Map.addLayer(
    carbon, {
      min: 1,
      max: 180,
      palette: ['d9f0a3', 'addd8e', '78c679', '41ab5d', '238443', '005a32']
    },
    'carbon_tonnes_per_ha');


// Organic soil emissions ===========
// Load data
var croplandc = ee.ImageCollection("FAO/GHG/1/DROSE_A")
.select('croplandc').filterDate("2017-01-01", "2017-12-31").median();

// Clip to the output image to the geometry boundary.
var croplandc = croplandc.clip(geometry);

Map.addLayer(
    croplandc, {palette: ['#B5651D', '673400']},
    'cropland peat emission Gg');
    
    

// Export and save to drive ==========
Export.image.toDrive({
  image: cover2000,
  description: 'treecover_2000',
  scale: 90,
  fileFormat: 'GeoTIFF',
  region: geometry
});

Export.image.toDrive({
  image: lossyear,
  description: 'lossyear',
  scale: 90,
  fileFormat: 'GeoTIFF',
  region: geometry
});


Export.image.toDrive({
  image: carbon,
  description: 'carbon_t_per_ha',
  scale: 300,
  fileFormat: 'GeoTIFF',
  region: geometry
});


Export.image.toDrive({
  image: croplandc,
  description: 'peat_carbon_emittion_Gg',
  scale: 927.67,
  fileFormat: 'GeoTIFF',
  region: geometry
});

