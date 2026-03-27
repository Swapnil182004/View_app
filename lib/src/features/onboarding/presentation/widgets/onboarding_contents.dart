class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Complete online courses",
    image: "assets/images/image1.png",
    desc: "From science to coding to design, we have it all.",
  ),
  OnboardingContents(
    title: "Stay organized with your teachers",
    image: "assets/images/image2.png",
    desc:
        "Take control of your schedule, collaborate live or on your own time.",
  ),
  OnboardingContents(
    title: "Get prority student support",
    image: "assets/images/image3.png",
    desc:
        "We are here for you. We are here for you. We are here for you.",
  ),
];
