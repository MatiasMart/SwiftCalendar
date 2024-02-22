//
//  ParticleEffect.swift
//  SwiftCalendar
//
//  Created by Matias Martinelli on 22/02/2024.
//

import SwiftUI

//Custom View Modifier
extension View {
    @ViewBuilder
    func particleEffect(systemImage: String, font: Font, status: Bool, activeTint: Color, inActiveTint: Color) -> some View {
        self
            .modifier(
                ParticleModifier(systemImage: systemImage, font: font, status: status, activeTint: activeTint, inActiveTint: inActiveTint)
            )
    }
}

fileprivate struct ParticleModifier: ViewModifier {
    var systemImage: String
    var font: Font
    var status: Bool
    var activeTint: Color
    var inActiveTint: Color
    //View Properties
    @State private var particles: [Particle] = []
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                ZStack {
                    ForEach(particles) { particle in
                        Image(systemName: systemImage)
                            .foregroundStyle(status ? activeTint : inActiveTint)
                            .scaleEffect(particle.scale)
                            .offset(x: particle.randomX, y: particle.randomY)
                            .opacity(particle.opacity)
                            // Only visible when status is active
                            .opacity(status ? 1 : 0)
                            .animation(.none, value: status)
                    }
                }
                .onAppear {
                    //Adding base particles for animation
                    for _ in 1...15 {
                        let particle = Particle()
                        particles.append(particle)
                    }
                }
                .onChange(of: status) { newValue in
                    if !newValue {
                        // Reset animation
                        for i in particles.indices {
                            particles[i].reset()
                        }
                    }else {
                        // Activating particles
                        for i in particles.indices {
                            //Random X & Y Calculation Based on Index
                            let total: CGFloat = CGFloat(particles.count)
                            let progress: CGFloat = CGFloat(i) / total
                            
                            let maxX: CGFloat = (progress > 0.5) ? 100 : -100
                            let maxY: CGFloat = 60
                            
                            let randomX: CGFloat = ((progress > 0.5 ? progress - 0.5 : progress) * maxX)
                            let randomY: CGFloat = ((progress > 0.5 ? progress - 0.5 : progress) * maxY) + 35
                            
                            // Min Scale = 0.35
                            // Max Scale = 1
                            let randomScale: CGFloat = .random(in: 0.35...1)
                            
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                                // Extra Random Values For Spreading Particles Across the view
                                let extraRandomX: CGFloat = (progress < 0.5 ? .random(in: 0...10) : .random(in: -10...0))
                                let extraRandomY: CGFloat =  .random(in: 0...30)
                                
                                particles[i].randomX = randomX + extraRandomX
                                particles[i].randomY = -randomY - extraRandomY
                            }
                            
                            // Scaling with ease animation
                            withAnimation(.easeInOut(duration: 0.3)) {
                                particles[i].scale = randomScale
                            }
                            
                            // Removing Particles Based on index
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7).delay(0.25 + (Double(i) * 0.005))) {
                                particles[i].scale = 0.001
                            }
                        }
                    }
                }
            }
    }
}

struct ParticleEffect_Preview: PreviewProvider {
    static var previews: some View {
        // Use the dummy view to trigger the particleEffect modifier
        Text("Hello, ParticleEffect!")
            .particleEffect(systemImage: "heart.fill", font: .title, status: true, activeTint: .red, inActiveTint: .blue)
    }
}
