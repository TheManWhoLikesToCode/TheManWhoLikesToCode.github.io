---
layout: post
title: SpotiFind
description: K-Means Cluster Based Song Recommendations
---
<p align="center">
  <img src="support/SpotiFind.png" alt="SpotiFind Logo">
</p>

# Spotify-Recommendation-System

## Description
The Spotify-Recommendation-System is a project called SpotiFind, that aims to provide personalized song recommendations based on audio features obtained from the Spotify Web API. By leveraging machine learning techniques and K-means clustering, this system groups songs with similar characteristics and suggests new tracks that align with users' musical preferences. The project SpotiFind is a practical implementation of the concepts discussed in the paper "Audio Feature K-Means Cluster-Based Song Recommendation" by Jaydin Freeman.

## Usage
To use the Spotify-Recommendation-System, follow these steps:

1. Clone the repository: `git clone https://github.com/TheManWhoLikesToCode/SpotIFind.git`.

2. Install the required dependencies: `pip install -r requirements.txt`.

3. Set up your Spotify developer account and obtain the necessary API credentials.

4. Update the configuration file `config.yaml` with your Spotify API credentials.

5. Run the application using the provided scripts.

6. Access the web interface in your browser at `http://localhost:5000` and start discovering personalized song recommendations!

## Technical Overview
SpotiFind uses K-means clustering to group songs based on various audio features such as acousticness, danceability, energy, and more. The system retrieves user's favorite tracks from their Spotify account and clusters them based on their audio features. It then compares these clusters to a dataset of songs and recommends songs similar to each cluster's centroid.

### Data Collection & Preparation
Data is collected from the user's Spotify account through the Spotify authentication API. The audio features of the songs are then loaded into a Pandas DataFrame for manipulation. These features are standardized and normalized to ensure all features have the same scale.

### Dimensionality Reduction
t-SNE (t-Distributed Stochastic Neighbor Embedding) is used for dimensionality reduction. This algorithm reduces high-dimensional data into a 2D space for visualization purposes, preserving the structure of the data.

### Data Fitting & Clustering
KMeans algorithm is used for clustering. Songs are assigned to clusters based on their features, and centroids are calculated for each cluster. The centroids represent the average song within each cluster.

### Evaluation
The model evaluates the defining characteristics of each cluster and visualizes the clusters for analysis. The songs in each cluster are recommended to the user based on their preferences.

## Results and Demonstration
<p align="center">
  <img src="support/Demonstration.gif" alt="Demonstration" width="1280" height="720">
</p>

<p align="center">
  <img src="support/Figure_1.png" alt="Figure 1" width="480">
</p>

<p align="center">
  <img src="support/Figure_2.png" alt="Figure 2" width="480">
</p>

Include videos and images to demonstrate the application's functionality and results.

## Accompanying Paper
The project is accompanied by a paper titled "Audio Feature K-Means Cluster-Based Song Recommendation" by Jaydin Freeman, which goes into a more detailed technical discussion, results, and conclusions. The paper also contains an appendix of code and references.

### Sections in the Paper:
- Overview
- Introduction
- Technical Discussion and Results
- Conclusion
- References
- Appendix of Code

## Future Work
- Integration of User Feedback
- Enhancing Visualization and Playlist Generation
- Streamlining Login Functionality

Future development of SpotiFind will include integrating user feedback, enhancing visualizations, and automating playlist generation. It is also aimed to streamline the login functionality for a better user experience.

## References

- Elruby, A. (2023). Spotify-Recommendation-System [GitHub repository]. Retrieved from https://github.com/abdelrhmanelruby/Spotify-Recommendation-System

- McFee, B., Raffel, C., & Ellis, D. P. (2015). "Librosa: Audio and music signal analysis in Python." Proceedings of the 14th Python in Science Conference.

- Wang, C., & Blei, D. M. (2011). "Collaborative topic modeling for recommending scientific articles." Proceedings of the 17th ACM SIGKDD International Conference on Knowledge Discovery and Data Mining.
[Go to repository](https://github.com/TheManWhoLikesToCode/SpotiFind)
