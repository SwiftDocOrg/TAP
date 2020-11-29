class MockOutputStream: TextOutputStream {
    var text: String = ""

    func write(_ string: String) {
        text += string
    }
}
