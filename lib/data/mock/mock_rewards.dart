import '../../business/rewards/entities/reward.dart';

final _epoch = DateTime(2025, 1, 1);

final List<Reward> mockRewards = [
  Reward(
    id: 'r_1',
    name: 'Movie Tickets',
    imageUrl:
        'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=400&auto=format&fit=crop',
    description:
        'Two tickets to any movie at a local theater. A great way to unwind and enjoy a film of your choice.',
    cost: 50,
    type: RewardType.individual,
    createdAt: _epoch,
    updatedAt: _epoch,
  ),
  Reward(
    id: 'r_2',
    name: 'Pizza Party',
    imageUrl:
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=400&auto=format&fit=crop',
    description:
        'Your entire team gets a full pizza party with drinks. Celebrate your hard work together!',
    cost: 200,
    type: RewardType.team,
    createdAt: _epoch,
    updatedAt: _epoch,
  ),
  Reward(
    id: 'r_3',
    name: 'Wireless Earbuds',
    imageUrl:
        'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?q=80&w=400&auto=format&fit=crop',
    description:
        'Premium wireless earbuds perfect for music, podcasts, and staying focused during study sessions.',
    cost: 250,
    type: RewardType.individual,
    createdAt: _epoch,
    updatedAt: _epoch,
  ),
  Reward(
    id: 'r_4',
    name: 'Team Hoodies',
    imageUrl:
        'https://images.unsplash.com/photo-1556821840-3a63f15732ce?q=80&w=400&auto=format&fit=crop',
    description:
        'Custom High Aspirations hoodies for every member of your team. Rep your squad in style.',
    cost: 300,
    type: RewardType.team,
    createdAt: _epoch,
    updatedAt: _epoch,
  ),
  Reward(
    id: 'r_5',
    name: 'Book of Choice',
    imageUrl:
        'https://images.unsplash.com/photo-1512820790803-83ca734da794?q=80&w=400&auto=format&fit=crop',
    description:
        'Pick any book you want — fiction, self-help, or a textbook. Invest in your knowledge.',
    cost: 30,
    type: RewardType.individual,
    createdAt: _epoch,
    updatedAt: _epoch,
  ),
  Reward(
    id: 'r_6',
    name: 'Escape Room',
    imageUrl:
        'https://images.unsplash.com/photo-1590600421003-dd3e5fdf0b2c?q=80&w=400&auto=format&fit=crop',
    description:
        'Your team gets to tackle a themed escape room challenge together. Teamwork makes the dream work!',
    cost: 350,
    type: RewardType.team,
    createdAt: _epoch,
    updatedAt: _epoch,
  ),
  Reward(
    id: 'r_7',
    name: '\$25 Gift Card',
    imageUrl:
        'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?q=80&w=400&auto=format&fit=crop',
    description:
        'A \$25 gift card to a retailer of your choice. Treat yourself to something special.',
    cost: 75,
    type: RewardType.individual,
    createdAt: _epoch,
    updatedAt: _epoch,
  ),
  Reward(
    id: 'r_8',
    name: 'Sports Jersey',
    imageUrl:
        'https://images.unsplash.com/photo-1511886929837-354d827aae26?q=80&w=400&auto=format&fit=crop',
    description:
        'An official jersey from your favorite sports team. Show off your team pride.',
    cost: 150,
    type: RewardType.individual,
    createdAt: _epoch,
    updatedAt: _epoch,
  ),
  Reward(
    id: 'r_9',
    name: 'Team Field Trip',
    imageUrl:
        'https://images.unsplash.com/photo-1528360983277-13d401cdc186?q=80&w=400&auto=format&fit=crop',
    description:
        'Your team earns a guided field trip to a local museum, science center, or cultural landmark.',
    cost: 500,
    type: RewardType.team,
    createdAt: _epoch,
    updatedAt: _epoch,
  ),
  Reward(
    id: 'r_10',
    name: 'Laptop Bag',
    imageUrl:
        'https://images.unsplash.com/photo-1547949003-9792a18a2601?q=80&w=400&auto=format&fit=crop',
    description:
        'A durable and stylish laptop backpack to carry all your gear with ease.',
    cost: 200,
    type: RewardType.individual,
    createdAt: _epoch,
    updatedAt: _epoch,
  ),
];
