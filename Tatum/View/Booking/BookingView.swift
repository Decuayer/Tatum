//
//  BookingView.swift
//  Tatum
//
//  Created by Demir Cücü on 20.12.2025.
//

import SwiftUI

struct BookingView: View {
    let studio: Studio
    @StateObject var viewModel = BookingViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color("BackgroundDark")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                headerView
                
                Text("Select Date")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                datePickerScroll
                
                Text("Available Slots")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                timeSlotGrid
                
                Spacer()
                
                confirmButton
            }
            .padding(.top, 20)
        }
    }
}

extension BookingView {
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(studio.name)
                    .font(.custom("Poppins-Bold", size: 20))
                    .foregroundColor(.white)
                Text("Book Appointment")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color("CardDark"))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
    }
    
    private var datePickerScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.nextDays, id: \.self) { date in
                    VStack(spacing: 8) {
                        Text(date.formatted(.dateTime.weekday(.abbreviated))) // "Mon"
                            .font(.custom("Poppins-Regular", size: 14))
                        
                        Text(date.formatted(.dateTime.day())) // "21"
                            .font(.custom("Poppins-Bold", size: 18))
                    }
                    .foregroundColor(Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate) ? .white : .gray)
                    .frame(width: 60, height: 80)
                    .background(
                        Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
                        ? Color("BrandPurple")
                        : Color("CardDark")
                    )
                    .cornerRadius(12)
                    .onTapGesture {
                        withAnimation {
                            viewModel.selectedDate = date
                            // Gün değişince saatleri yenile (İleride)
                            viewModel.selectedTimeSlot = nil
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var timeSlotGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            ForEach(viewModel.availableSlots, id: \.self) { slot in
                
                let isBooked = viewModel.isSlotBooked(time: slot)
                
                Text(slot)
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(isBooked ? .gray.opacity(0.5) : (viewModel.selectedTimeSlot == slot ? .white : .gray))
                    .strikethrough(isBooked) // Doluysa üstünü çiz
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        isBooked ? Color("CardDark").opacity(0.3) : // Doluysa silik
                        (viewModel.selectedTimeSlot == slot ? Color("BrandPurple") : Color("CardDark")) // Seçiliyse Mor
                    )
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: viewModel.selectedTimeSlot == slot ? 0 : 1)
                    )
                    .onTapGesture {
                        if !isBooked {
                            withAnimation {
                                viewModel.selectSlot(slot)
                            }
                        }
                    }
            }
        }
        .padding(.horizontal)
    }
    
    private var confirmButton: some View {
        Button(action: {
            if viewModel.selectedTimeSlot != nil {
                print("Proceed to Payment/Confirmation")
            }
        }) {
            Text("Confirm Booking")
                .font(.custom("Poppins-Bold", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(viewModel.selectedTimeSlot == nil ? Color.gray : Color("BrandPurple"))
                .cornerRadius(16)
        }
        .disabled(viewModel.selectedTimeSlot == nil)
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
}

