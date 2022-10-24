extension String {

    var imageName: String {
        switch self {
        case "SelfCheck":               return "pencil.line"
        case "Weight":                  return "speedometer"
        case "Steps":                   return "figure.walk"

            //MARK: - workout
        case "American Football":       return "figure.american.football"
        case "Archery":                 return "figure.archery"
        case "Australian Football":     return "figure.australian.football"
        case "Badminton":               return "figure.badminton"
        case "Baseball":                return "figure.baseball"
        case "Basketball":              return "figure.basketball"
        case "Bowling":                 return "figure.bowling"
        case "Boxing":                  return "figure.boxing"
        case "Climbing":                return "figure.climbing"
        case "Cross Training":          return "figure.cross.training"
        case "Curling":                 return "figure.curling"
        case "Cycling":                 return "figure.outdoor.cycle"
        case "Dance":                   return "figure.dance"
        case "Dance Inspired Training": return "figure.dance"
        case "Elliptical":              return "figure.elliptical"
        case "Equestrian Sports":      return "figure.equestrian.sports"
        case "Fencing":      return "figure.fencing"
        case "Fishing":      return "figure.fishing"
//        case "Functional Strength Training":      return ""
//        case "Golf":      return ""
//        case "Gymnastics":      return ""
//        case "Handball":      return ""
//        case "Hiking":      return ""
//        case "Hockey":      return ""
//        case "Hunting":      return ""
//        case "Lacrosse":      return ""
//        case "Martial Arts":      return ""
//        case "Mind and Body":      return ""
//        case "Mixed Metabolic Cardio Training":      return ""
//        case "Paddle Sports":      return ""
//        case "Play":      return ""
//        case "Preparation and Recovery":      return ""
//        case "Racquetball":      return ""
//        case "Rowing":      return ""
//        case "Rugby":      return ""
//        case "Running":      return ""
//        case "Sailing":      return ""
//        case "Skating Sports":      return ""
//        case "Snow Sports":      return ""
//        case "Soccer":      return ""
//        case "Softball":      return ""
//        case "Squash":      return ""
//        case "Stair Climbing":      return ""
//        case "Surfing Sports":      return ""
//        case "Swimming":      return ""
//        case "Table Tennis":      return ""
//        case "Tennis": return ""
//        case "Track and Field": return ""
//        case "Traditional Strength Training": return ""
//        case "Volleyball": return ""
//        case "Walking": return ""
//        case "Water Fitness": return ""
//        case "Water Polo": return ""
//        case "Water Sports": return ""
//        case "Wrestling": return ""
//        case "Yoga": return ""
//
//            //iOS 10
//        case "Barre": return ""
//        case "Core Training": return ""
//        case "Cross Country Skiing": return ""
//        case "Downhill Skiing": return ""
//        case "Flexibility": return ""
//        case "High Intensity Interval Training": return ""
//        case "Jump Rope": return ""
//        case "Kickboxing": return ""
//        case "Pilates": return ""
//        case "Snowboarding": return ""
//        case "Stairs": return ""
//        case "Step Training": return ""
//        case "Wheelchair Walk Pace": return ""
//        case "Wheelchair Run Pace": return ""
//
//            //iOS 11
//        case "Tai Chi": return ""
//        case "Mixed Cardio": return ""
//        case "Hand Cycling": return ""
//
//            //iOS 13
//        case "Disc Sports": return "figure.disc.sports"
//        case "Fitness Gaming": return ""

            // Catch-all
        default:                return "figure.mixed.cardio"
        }
    }
}
