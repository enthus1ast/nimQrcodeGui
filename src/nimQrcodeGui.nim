import strutils, pixie, nigui, QRgen, QRgen/renderer, cligen, os, std/tempfiles

proc gui() =
  var qr = newQR("https://github.com/aruZeta/QRgen", ecLevel=qrECH)
  var img = qr.renderImg("#1d2021","#98971a",100,100,25) #,img=readImage("QRgen-logo.png"))
  var fg = "#1d2021"
  var bg = "#98971a"
  var alignmentPatternsRoundness: int
  var modulesRoundness: int
  var separationOfTheModules: int
  var errorCorrection = qrECL
  var centerImagePath: string = ""

  app.init()
  var window = newWindow()
  window.width = 512
  window.height = 650

  var vertContainer = newLayoutContainer(Layout_Vertical)
  window.add vertContainer

  var control1 = newControl()
  vertContainer.add(control1)

  control1.widthMode = WidthMode_Fill
  control1.heightMode = HeightMode_Fill
  control1.width = 500
  control1.height = 500
  control1.onDraw = proc (event: DrawEvent) =
    let canvas = event.control.canvas
    var xx = 0
    var yy = 0
    for pix in img.data:
      xx.inc
      if xx == 512:
        xx = 0
        yy.inc
      canvas.setPixel(xx, yy, nigui.rgb(pix.r, pix.g, pix.b))
      

  var input = newTextBox()

  proc refresh(control: Control) =
    control1.hide()
    control1.show()

  template renderAndDraw() =
    try:
      qr = newQR(input.text, ecLevel=errorCorrection)
      if centerImagePath.len > 0:
        img = qr.renderImg(
            fg,
            bg,
            alignmentPatternsRoundness.Percentage,
            modulesRoundness.Percentage,
            separationOfTheModules.Percentage,
            img=readImage(centerImagePath)
          )
      else:
        img = qr.renderImg(
            fg,
            bg,
            alignmentPatternsRoundness.Percentage,
            modulesRoundness.Percentage,
            separationOfTheModules.Percentage,
          )
      control1.refresh()
    except:
      echo getCurrentExceptionMsg()

  var inputfb = newTextBox()
  inputfb.text = fg
  inputfb.onTextChange = proc(event: TextChangeEvent) =
    fg = inputfb.text
    renderAndDraw()
   

  var inputbg = newTextBox()
  inputbg.text = bg
  inputbg.onTextChange = proc(event: TextChangeEvent) =
    bg = inputbg.text
    renderAndDraw()

  var alignmentPatternsRoundnessText = newTextBox()
  alignmentPatternsRoundnessText.text = "60"
  alignmentPatternsRoundnessText.onTextChange = proc(event: TextChangeEvent) =
    try:
      alignmentPatternsRoundness = alignmentPatternsRoundnessText.text.parseInt
      renderAndDraw()
    except:
      echo getCurrentExceptionMsg()

  var modulesRoundnessText = newTextBox()
  modulesRoundnessText.text = "60"
  modulesRoundnessText.onTextChange = proc(event: TextChangeEvent) =
    try:
      modulesRoundness = modulesRoundnessText.text.parseInt
      renderAndDraw()
    except:
      echo getCurrentExceptionMsg()

  var separationOfTheModulesText = newTextBox()
  separationOfTheModulesText.text = "60"
  separationOfTheModulesText.onTextChange = proc(event: TextChangeEvent) =
    try:
      separationOfTheModules = separationOfTheModulesText.text.parseInt
      renderAndDraw()
    except:
      echo getCurrentExceptionMsg()

  var errorCorrectionComboBox = newComboBox(@[
      "qrECL, #  8% data recovery",
      "qrECM, # 15% data recovery",
      "qrECQ, # 25% data recovery",
      "qrECH  # 30% data recovery",
    ])
  errorCorrectionComboBox.onChange = proc(event: ComboBoxChangeEvent) =
    case errorCorrectionComboBox.index
    of 0: errorCorrection = qrECL #  7% data recovery
    of 1: errorCorrection = qrECM # 15% data recovery
    of 2: errorCorrection = qrECQ # 25% data recovery
    of 3: errorCorrection = qrECH # 30% data recovery
    else: errorCorrection = qrECL #
    renderAndDraw()


  input.onTextChange = proc(event: TextChangeEvent) =
    renderAndDraw()

  ## The add center image
  var addCenterImageDialog = newOpenFileDialog()
  # addCenterImageDialog.defaultExtension = ".png"
  var addCenterImageDialogButton = newButton("add center image")
  addCenterImageDialogButton.onClick = proc(event: ClickEvent) =
    addCenterImageDialog.run()
    if addCenterImageDialog.files.len > 0:
      centerImagePath = addCenterImageDialog.files[0]
      errorCorrection = qrECH # 30% data recovery
      errorCorrectionComboBox.index = 3
      renderAndDraw()

  ## The safe image Dialog
  var safeFileDialog = newSaveFileDialog()
  safeFileDialog.defaultExtension = ".png"
  var safeFileDialogButton = newButton("save image (.png)")
  # defaultExtension: "", defaultName: ""
  safeFileDialogButton.onClick = proc(event: ClickEvent) =
    safeFileDialog.run()
    if safeFileDialog.file.len > 0:
      writeFile(img,safeFileDialog.file)

  vertContainer.add(input)

  var colorContainer = newLayoutContainer(Layout_Horizontal)
  vertContainer.add colorContainer
  colorContainer.add(inputfb)
  colorContainer.add(inputbg)

  var roundnessContainer = newLayoutContainer(Layout_Horizontal)
  vertContainer.add roundnessContainer
  roundnessContainer.add(alignmentPatternsRoundnessText)
  roundnessContainer.add(modulesRoundnessText)
  roundnessContainer.add(separationOfTheModulesText)
  roundnessContainer.add(errorCorrectionComboBox)

  var openSaveContainer = newLayoutContainer(Layout_Horizontal)
  vertContainer.add openSaveContainer
  openSaveContainer.add(addCenterImageDialogButton)
  openSaveContainer.add(safeFileDialogButton)

  window.show()
  app.run()


proc cli(text: string, alignmentPatternsRoundness, modulesRoundness, separationOfTheModules: int, 
    errorCorrection: QREcLevel, centerImagePath: string = "", output: string = "", fg = "black", bg = "white") =

  var img: pixie.Image

  if centerImagePath.len > 0 and errorCorrection != qrECH:
    echo "for center images, it is recommended to use higher error correction: qrECH"

  try:
    var qr = newQR(text, ecLevel=errorCorrection)
    if centerImagePath.len > 0:
      img = qr.renderImg(
          bg,
          fg,
          alignmentPatternsRoundness.Percentage,
          modulesRoundness.Percentage,
          separationOfTheModules.Percentage,
          img=readImage(centerImagePath)
        )
    else:
      img = qr.renderImg(
          bg,
          fg,
          alignmentPatternsRoundness.Percentage,
          modulesRoundness.Percentage,
          separationOfTheModules.Percentage,
        )
  except:
    echo getCurrentExceptionMsg()
    quit(1)
  var outputPath: string = output
  if outputPath == "":
    outputPath = genTempPath("qr", ".png")
  img.writeFile(outputPath)
  echo "Written to: ", outputPath


when isMainModule:
  if paramCount() == 0:
    gui()
  else:
    dispatch(cli)
