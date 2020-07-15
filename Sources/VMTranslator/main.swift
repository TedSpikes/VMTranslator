import VMTranslatorCore

let translator = VMTranslator()

do {
    try translator.run()
} catch {
    print("An error occurred: \(error)")
}
