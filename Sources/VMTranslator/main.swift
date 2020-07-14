import VMTranslatorCore

let translator = VMTranslator()

do {
    try translator.run()
} catch {
    print("Whoops! An error occurred: \(error)")
}
