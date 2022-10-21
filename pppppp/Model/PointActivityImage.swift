extension String {

    var imageName: String {
        switch self {
        case "SelfCheck":
            return "pencil.line"
        case "Weight":
            return "speedometer"
        case "Steps":
            return "figure.walk"

        case "Basketball":
            return "figure.basketball"
        case "Swim":
            return "figure.pool.swim"
            
        default:
            return "figure.mixed.cardio"
        }
    }
}
