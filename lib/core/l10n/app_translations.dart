class AppTranslations {
  final String locale;

  const AppTranslations(this.locale);

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'my_kamjari': 'My Kamjari',
      'good_morning': 'Good morning,',
      'todays_estate_plan': 'Today\'s Estate Plan',
      'no_active_plans': 'No active plans assigned to you today.',
      'ask_manager': 'Ask your Manager to create an Estate Plan.',
      'section': 'Section',
      'target': 'Target:',
      'gangs': 'Gangs:',
      'none_assigned': 'None assigned',
      'tap_to_take_hazira': 'Tap to take Hazira (Attendance)',
      'log_inspection': 'Log Inspection',
      'close_day': 'Close Day',
      'no_active_to_close': 'No active plans to close.',
      'plans_closed': 'plan(s) closed successfully!',
      'weighing_station': 'Weighing Station',
      'total_collected': 'Total Collected',
      'workers_processed': 'Workers Processed',
      'enter_id': 'ENTER ID',
      'dispatch_transport': 'Dispatch Transport',
      'ready_for_next': 'Ready for next worker...',
      'attendance_roster': 'Attendance Roster',
      'scan_qr': 'Scan QR',
      'workers_present': 'workers present',
      'submit_hazira': 'Submit Hazira',
      'search_pf': 'Search PF Number...',
      'present': 'Present',
      'absent': 'Absent',
    },
    'bn': {
      'my_kamjari': 'আমার কামজারি',
      'good_morning': 'সুপ্রভাত,',
      'todays_estate_plan': 'আজকের এস্টেট প্ল্যান',
      'no_active_plans': 'আজ আপনার জন্য কোনো প্ল্যান নেই।',
      'ask_manager': 'আপনার ম্যানেজারকে একটি এস্টেট প্ল্যান তৈরি করতে বলুন।',
      'section': 'সেকশন',
      'target': 'টার্গেট:',
      'gangs': 'গ্যাং:',
      'none_assigned': 'কোনোটি বরাদ্দ নেই',
      'tap_to_take_hazira': 'হাজিরা নিতে ট্যাপ করুন',
      'log_inspection': 'পরিদর্শন লগ করুন',
      'close_day': 'দিন শেষ করুন',
      'no_active_to_close': 'বন্ধ করার মতো কোনো প্ল্যান নেই।',
      'plans_closed': 'টি প্ল্যান সফলভাবে বন্ধ করা হয়েছে!',
      'weighing_station': 'ওজন কেন্দ্র',
      'total_collected': 'মোট সংগৃহীত',
      'workers_processed': 'কর্মীদের প্রক্রিয়া করা হয়েছে',
      'enter_id': 'আইডি প্রবেশ করুন',
      'dispatch_transport': 'পরিবহন পাঠান',
      'ready_for_next': 'পরবর্তী কর্মীর জন্য প্রস্তুত...',
      'attendance_roster': 'হাজিরার তালিকা',
      'scan_qr': 'কিউআর স্ক্যান করুন',
      'workers_present': 'কর্মী উপস্থিত',
      'submit_hazira': 'হাজিরা জমা দিন',
      'search_pf': 'পিএফ নম্বর খুঁজুন...',
      'present': 'উপস্থিত',
      'absent': 'অনুপস্থিত',
    }
  };

  String translate(String key) {
    return _translations[locale]?[key] ?? _translations['en']?[key] ?? key;
  }
}
