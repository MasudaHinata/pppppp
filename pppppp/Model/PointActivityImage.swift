extension String {

    var imageName: String {
        switch self {
        case "SelfCheck":
            return "pencil.line"
        case "Weight":
            return "speedometer"
        case "Steps":
            return "figure.walk"
        default:
            return "figure.mixed.cardio"
        }
    }
}
