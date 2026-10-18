import SwiftUI

struct AnalogClockFace: View {
    let date: Date
    var size: CGFloat = 200
    var showNumbers: Bool = true

    private var calendar: Calendar { Calendar.current }

    private var hourAngle: Angle {
        let hour = Double(calendar.component(.hour, from: date) % 12)
        let minute = Double(calendar.component(.minute, from: date))
        let second = Double(calendar.component(.second, from: date))
        let totalHourFraction = (hour + minute / 60.0 + second / 3600.0) / 12.0
        return .degrees(totalHourFraction * 360)
    }

    private var minuteAngle: Angle {
        let minute = Double(calendar.component(.minute, from: date))
        let second = Double(calendar.component(.second, from: date))
        let totalMinuteFraction = (minute + second / 60.0) / 60.0
        return .degrees(totalMinuteFraction * 360)
    }

    private var secondAngle: Angle {
        let second = Double(calendar.component(.second, from: date))
        return .degrees(Double(second) / 60.0 * 360)
    }

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let radius = min(canvasSize.width, canvasSize.height) / 2

            // --- Face background ---
            let faceRect = CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )
            let facePath = Path(ellipseIn: faceRect)

            let gradient = Gradient(colors: [
                Color(white: 0.18),
                Color(white: 0.13)
            ])
            context.fill(
                facePath,
                with: .radialGradient(gradient, center: center, startRadius: 0, endRadius: radius)
            )

            // Subtle outer ring
            let outerRingCtx = context
            outerRingCtx.stroke(
                facePath,
                with: .color(Color(white: 0.28)),
                lineWidth: 2
            )

            // --- Tick marks ---
            for i in 0..<60 {
                let angle = Double(i) / 60.0 * 2 * .pi - .pi / 2
                let isMajor = i % 5 == 0
                let isCardinal = i % 15 == 0

                let outerRadius = radius - 4
                let innerRadius: CGFloat
                let tickWidth: CGFloat
                let tickColor: Color

                if isCardinal {
                    innerRadius = radius - 18
                    tickWidth = 2.5
                    tickColor = Color(white: 0.85)
                } else if isMajor {
                    innerRadius = radius - 14
                    tickWidth = 1.8
                    tickColor = Color(white: 0.7)
                } else {
                    innerRadius = radius - 8
                    tickWidth = 0.8
                    tickColor = Color(white: 0.4)
                }

                let outerPoint = CGPoint(
                    x: center.x + cos(angle) * outerRadius,
                    y: center.y + sin(angle) * outerRadius
                )
                let innerPoint = CGPoint(
                    x: center.x + cos(angle) * innerRadius,
                    y: center.y + sin(angle) * innerRadius
                )

                var tickPath = Path()
                tickPath.move(to: outerPoint)
                tickPath.addLine(to: innerPoint)

                context.stroke(
                    tickPath,
                    with: .color(tickColor),
                    style: StrokeStyle(lineWidth: tickWidth, lineCap: .round)
                )
            }

            // --- Hour numbers ---
            if showNumbers {
                let numberRadius = radius - 30
                for hour in 1...12 {
                    let angle = Double(hour) / 12.0 * 2 * .pi - .pi / 2
                    let point = CGPoint(
                        x: center.x + cos(angle) * numberRadius,
                        y: center.y + sin(angle) * numberRadius
                    )

                    let isCardinalHour = hour % 3 == 0
                    let fontSize: CGFloat = isCardinalHour ? radius * 0.16 : radius * 0.13
                    let fontWeight: Font.Weight = isCardinalHour ? .semibold : .regular
                    let fontColor: Color = isCardinalHour ? Color(white: 0.9) : Color(white: 0.6)

                    let text = Text("\(hour)")
                        .font(.system(size: fontSize, weight: fontWeight, design: .rounded))
                        .foregroundColor(fontColor)

                    let resolved = context.resolve(text)
                    let textSize = resolved.measure(in: canvasSize)
                    let textOrigin = CGPoint(
                        x: point.x - textSize.width / 2,
                        y: point.y - textSize.height / 2
                    )
                    context.draw(resolved, at: CGPoint(x: textOrigin.x + textSize.width / 2, y: textOrigin.y + textSize.height / 2))
                }
            }

            // --- Clock hands ---

            // Shadow helper: draw the hand offset slightly
            func drawHand(
                angle: Angle,
                length: CGFloat,
                width: CGFloat,
                color: Color,
                tailLength: CGFloat = 0
            ) {
                let radians = angle.radians - .pi / 2
                let tip = CGPoint(
                    x: center.x + cos(radians) * length,
                    y: center.y + sin(radians) * length
                )
                let tail = CGPoint(
                    x: center.x - cos(radians) * tailLength,
                    y: center.y - sin(radians) * tailLength
                )

                var handPath = Path()
                handPath.move(to: tail)
                handPath.addLine(to: tip)

                // Shadow
                var shadowCtx = context
                shadowCtx.addFilter(.shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1))
                shadowCtx.stroke(
                    handPath,
                    with: .color(color),
                    style: StrokeStyle(lineWidth: width, lineCap: .round)
                )
            }

            // Hour hand
            drawHand(
                angle: hourAngle,
                length: radius * 0.48,
                width: 4.5,
                color: Color(white: 0.92)
            )

            // Minute hand
            drawHand(
                angle: minuteAngle,
                length: radius * 0.68,
                width: 3.0,
                color: Color(white: 0.88)
            )

            // Second hand
            drawHand(
                angle: secondAngle,
                length: radius * 0.72,
                width: 1.5,
                color: Color.red,
                tailLength: radius * 0.15
            )

            // --- Center dot ---
            let dotRadius: CGFloat = 4.5
            let dotRect = CGRect(
                x: center.x - dotRadius,
                y: center.y - dotRadius,
                width: dotRadius * 2,
                height: dotRadius * 2
            )
            let dotPath = Path(ellipseIn: dotRect)

            var dotCtx = context
            dotCtx.addFilter(.shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1))
            dotCtx.fill(dotPath, with: .color(.red))

            // Inner highlight on center dot
            let innerDotRadius: CGFloat = 2
            let innerDotRect = CGRect(
                x: center.x - innerDotRadius,
                y: center.y - innerDotRadius,
                width: innerDotRadius * 2,
                height: innerDotRadius * 2
            )
            context.fill(Path(ellipseIn: innerDotRect), with: .color(Color(white: 0.95)))
        }
        .frame(width: size, height: size)
    }
}

struct AnalogClockFace_Previews: PreviewProvider {
    static var previews: some View {
        AnalogClockFace(date: Date(), size: 250)
            .padding()
            .background(Color(white: 0.08))
    }
}
