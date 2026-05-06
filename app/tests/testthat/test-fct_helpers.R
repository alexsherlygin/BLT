test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

test_that("read_image_raster supports JPEG and PNG inputs", {
  skip_if_not_installed("jpeg")
  skip_if_not_installed("png")

  img <- array(1, dim = c(2, 2, 3))
  jpg_path <- tempfile(fileext = ".jpg")
  png_path <- tempfile(fileext = ".png")

  jpeg::writeJPEG(img, jpg_path)
  png::writePNG(img, png_path)

  jpg_raster <- blt:::read_image_raster(jpg_path)
  png_raster <- blt:::read_image_raster(png_path)

  expect_s3_class(jpg_raster, "raster")
  expect_s3_class(png_raster, "raster")
  expect_equal(dim(jpg_raster), c(2, 2))
  expect_equal(dim(png_raster), c(2, 2))
})

test_that("image display dimensions account for EXIF orientation", {
  metadata <- data.frame(ImageWidth = 7952, ImageHeight = 5304, Orientation = 1)
  expect_equal(
    blt:::get_image_display_dimensions(metadata),
    c(width = 7952, height = 5304)
  )

  metadata$Orientation <- 8
  expect_equal(
    blt:::get_image_display_dimensions(metadata),
    c(width = 5304, height = 7952)
  )
})

test_that("image arrays are rotated to match EXIF browser orientation", {
  img <- matrix(1:6, nrow = 2, byrow = TRUE)

  expect_equal(
    blt:::orient_image_array(img, 6),
    matrix(c(4, 1, 5, 2, 6, 3), nrow = 3, byrow = TRUE)
  )

  expect_equal(
    blt:::orient_image_array(img, 8),
    matrix(c(3, 6, 2, 5, 1, 4), nrow = 3, byrow = TRUE)
  )
})

test_that("crop image dimensions follow the polygon bbox", {
  bbox <- c(xmin = 10.2, ymin = 20.4, xmax = 110.8, ymax = 71.1)
  dimensions <- blt:::get_crop_image_dimensions(bbox)

  expect_equal(dimensions[["width"]], 101L)
  expect_equal(dimensions[["height"]], 51L)

  tiny_bbox <- c(xmin = 10, ymin = 20, xmax = 10, ymax = 20)
  expect_equal(
    blt:::get_crop_image_dimensions(tiny_bbox),
    c(width = 1L, height = 1L)
  )
})

test_that("scaled workbook image dimensions preserve aspect ratio", {
  wide <- blt:::scale_dimensions_to_fit(
    width = 1000,
    height = 200,
    max_width = 2.3,
    max_height = 1.2
  )
  expect_equal(wide[["width"]], 2.3)
  expect_equal(wide[["height"]], 0.46)

  tall <- blt:::scale_dimensions_to_fit(
    width = 300,
    height = 1200,
    max_width = 2.3,
    max_height = 1.2
  )
  expect_equal(tall[["width"]], 0.3)
  expect_equal(tall[["height"]], 1.2)
})
