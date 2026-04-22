test_that("edit_annotation_data ignores zero-length field updates", {
  annotations <- blt:::create_user_dataframe()

  expect_warning(
    annotations <- blt:::edit_annotation_data(
      myUserAnnotationsData = annotations,
      myId = 1,
      myUser = "tester",
      myImage = "image.jpg",
      myFeatureType = "Point-map",
      myGeometry = "POINT(0 0)",
      myDD1 = "WT-1",
      myDD4 = "roof-edge"
    ),
    "No matching ID found"
  )

  expect_equal(nrow(annotations), 1)
  expect_identical(annotations$dd1[[1]], "WT-1")
  expect_identical(annotations$dd4[[1]], "roof-edge")

  updated <- expect_no_error(
    blt:::edit_annotation_data(
      myUserAnnotationsData = annotations,
      myId = 1,
      myDD1 = character(0),
      myDD4 = NULL
    )
  )

  expect_equal(nrow(updated), 1)
  expect_identical(updated$dd1[[1]], "WT-1")
  expect_identical(updated$dd4[[1]], "roof-edge")
})
