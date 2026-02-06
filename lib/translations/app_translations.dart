import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'km_KH': {
      // Settings
      'settings': 'ការកំណត់',
      'profile': 'ប្រវត្តិរូប',
      'places': 'ទីកន្លែង',
      'areas': 'តំបន់',
      'categories': 'ប្រភេទ',

      // Theme
      'light_mode': 'របៀបពន្លឺ',
      'dark_mode': 'របៀបងងឹត',
      'switch_to_light': 'ប្តូរទៅរបៀបពន្លឺ',
      'switch_to_dark': 'ប្តូរទៅរបៀបងងឹត',

      // Language
      'language': 'ភាសា',
      'khmer': 'ភាសាខ្មែរ',
      'english': 'ភាសាអង់គ្លេស',
      'select_language': 'ជ្រើសរើសភាសា',

      //Login
      'welcome_message': 'ស្វាគមន៍មកកាន់ការធ្វើដំណើរ',
      'travel_message': 'ទេសចរណ៍ឆ្លាតវៃ សម្រាប់អ្នក',
      'loading': 'កំពុងរៀបចំដំណើររបស់អ្នក...',
      'login_prompt': 'ចូលទៅក្នុងគណនីរបស់អ្នកដើម្បីចាប់ផ្តើមការផ្សងព្រេងថ្មីៗ!',
      'email_or_username': 'អ៊ីមែល ឬ ឈ្មោះអ្នកប្រើប្រាស់',
      'password': 'ពាក្យសម្ងាត់',
      'error_invalid_credentials':
          'ព័ត៌មានសម្ងាត់មិនត្រឹមត្រូវ។ សូមព្យាយាមម្តងទៀត។',
      'error': 'មានអ្វីមួយមិនត្រឹមត្រូវ។ សូមព្យាយាមម្តងទៀត។',
      'reset_password_prompt':
          'បញ្ចូលអ៊ីមែលរបស់អ្នកដើម្បីកំណត់ពាក្យសម្ងាត់ឡើងវិញ',
      'forgot_password': 'ភ្លេចពាក្យសម្ងាត់?',
      'please_fill_email_and_password':
          'សូមបំពេញអ៊ីមែល និង ពាក្យសម្ងាត់ដើម្បីចូល',
      'login_failed': 'ការចូលគណនីបានបរាជ័យ',
      'login': 'ចូលគណនី',
      'signup_prompt': 'មិនមានគណនី? ចុះឈ្មោះ',
      'register': 'ចុះឈ្មោះ',

      //Register
      'register_welcome_message': 'ចាប់ផ្តើមការស្វែងរកភាពល្អនៃពិភពលោក។',
      'full_name': 'ឈ្មោះពេញ',
      'email': 'អ៊ីមែល',
      'password_hint': 'បង្កើតពាក្យសម្ងាត់ដែលមានសុវត្ថិភាព',
      'please_fill_all_fields': 'សូមបំពេញវាលដែលត្រូវការ​ទាំងអស់',
      'invalid_image_url': 'URL របស់រូបភាពមិនត្រឹមត្រូវ',
      'account_created': 'គណនីត្រូវបានបង្កើត! សូមស្វាគមន៍មកកាន់App។',
      'registration_failed': 'ការចុះឈ្មោះបានបរាជ័យ',
      'sign_up': 'ចុះឈ្មោះ',
      'already_have_account': 'មានគណនីរួចហើយ?',

      //Home Screen
      'favorite': 'ការពេញចិត្ត',
      'logout': 'ចាកចេញ',
      'home': 'ទំព័រដើម',
      'login_required': 'ចាំបាច់ចូលគណនី',
      'please_login_to_manage_favorites':
          'សូមចូលគណនីដើម្បីគ្រប់គ្រងការពេញចិត្ត',
      'removed_from_favorites': 'បានដកចេញពីការពេញចិត្ត',
      'added_to_favorites': 'បានបន្ថែមទៅការពេញចិត្ត',
      'explore_new_places': 'ទៅស្វែងរកកន្លែងថ្មី!',
      'search_places': 'ស្វែងរកកន្លែង...',
      'tourism_experiences': 'ទេសចរណ៍ពេញនិយម',
      'special_places': 'កន្លែងពិសេសៗ',
      'no_special_places': 'គ្មានកន្លែងពិសេសទេ',
      'no_popular_places': 'គ្មានកន្លែងពេញនិយមទេ',
      'no_users_found': 'គ្មានប្រើប្រាស់ដែលផ្ទៀងផ្ទាត់ទេ',
      'profile_image_url': 'URL របស់រូបភាពប្រវត្តិរូប',
      'name_required': 'ឈ្មោះគឺជាមុខតំណាងដែលត្រូវបានទាមទារ',
      'save_changes': 'រក្សាទុកការផ្លាស់ប្តូរ',
      'new_message': 'សារថ្មីៗ',
      'new_reviews': 'ការវាយតំលៃថ្មីៗ',
      'no_review_notifications': 'គ្មានការជូនដំណឹងពីការវាយតំលៃទេ',
    },
    'en_US': {
      // Settings
      'settings': 'Settings',
      'profile': 'Profile',
      'places': 'Places',
      'areas': 'Areas',
      'categories': 'Categories',

      // Theme
      'light_mode': 'Light Mode',
      'dark_mode': 'Dark Mode',
      'switch_to_light': 'Switch to Light Mode',
      'switch_to_dark': 'Switch to Dark Mode',

      // Language
      'language': 'Language',
      'khmer': 'Khmer',
      'english': 'English',
      'select_language': 'Select Language',

      //Login
      'welcome_message': 'Welcome to Travel',
      'travel_message': 'Smart Tourism for You',
      'loading': 'Preparing your journey...',
      'login_prompt': 'Log in to your account to start new adventures!',
      'email_or_username': 'Email or Username',
      'password': 'Password',
      'error_invalid_credentials': 'Invalid credentials. Please try again.',
      'error': 'Something went wrong. Please try again.',
      'reset_password_prompt': 'Enter your email to reset password',
      'forgot_password': 'Forgot Password?',
      'please_fill_email_and_password':
          'Please fill email and password to login',
      'login_failed': 'Login Failed',
      'login': 'Login',
      'signup_prompt': 'Don\'t have an account? Sign Up',
      'register': 'Register',

      //Register
      'register_welcome_message': 'Start exploring the beauty of the world.',
      'full_name': 'Full Name',
      'email': 'Email',
      'password_hint': 'Create a strong password',
      'please_fill_all_fields': 'Please fill all required fields',
      'invalid_image_url': 'Invalid image URL',
      'account_created': 'Account created! Welcome aboard.',
      'registration_failed': 'Registration Failed',
      'sign_up': 'Sign Up',
      'already_have_account': 'Already have an account?',

      //Home Screen
      'favorite': 'Favorite',
      'logout': 'Logout',
      'home': 'Home',
      'login_required': 'Login Required',
      'please_login_to_manage_favorites': 'Please login to manage favorites',
      'removed_from_favorites': 'Removed from favorites',
      'added_to_favorites': 'Added to favorites',
      'explore_new_places': 'Explore New Places!',
      'search_places': 'Search Places...',
      'tourism_experiences': 'Popular Tourism Experiences',
      'special_places': 'Special Places',
      'no_special_places': 'No special places available',
      'no_popular_places': 'No popular places available',
      'no_users_found': 'No verified users found',
      'profile_image_url': 'Profile Image URL',
      'name_required': 'Name is required',
      'save_changes': 'Save Changes',
      'new_message': 'New Messages',
      'new_reviews': 'New Reviews',
      'no_review_notifications': 'No review notifications',
    },
  };
}
