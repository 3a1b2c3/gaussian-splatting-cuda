#include "camera_utils.cuh"
#include <eigen3/Eigen/Dense>
#include <fstream>
#include <iostream>
#include <nlohmann/json.hpp>

void write_json_to_file(const std::string& filename, const nlohmann::json& json_data) {
    std::ofstream file(filename);
    if (file.is_open()) {
        file << json_data.dump(4); // Write the JSON data with indentation of 4 spaces
        file.close();
        std::cout << "JSON data written to file: " << filename << std::endl;
    } else {
        std::cerr << "Unable to open file: " << filename << std::endl;
    }
}

// serialize camera to json
nlohmann::json camera_to_JSON(Camera cam) {

    Eigen::Matrix4d Rt = Eigen::Matrix4d::Zero();
    Rt.block<3, 3>(0, 0) = cam._R.transpose();
    Rt.block<3, 1>(0, 3) = cam._T;
    Rt(3, 3) = 1.0;

    Eigen::Matrix4d W2C = Rt.inverse();
    Eigen::Vector3d pos = W2C.block<3, 1>(0, 3);
    Eigen::Matrix3d rot = W2C.block<3, 3>(0, 0);
    std::vector<std::vector<double>> serializable_array_2d;
    for (int i = 0; i < rot.rows(); i++) {
        serializable_array_2d.push_back(std::vector<double>(rot.row(i).data(), rot.row(i).data() + rot.row(i).size()));
    }

    nlohmann::json camera_entry = {
        {"id", cam._camera_ID},
        {"img_name", cam._image_name},
        {"width", cam._width},
        {"height", cam._height},
        {"position", std::vector<double>(pos.data(), pos.data() + pos.size())},
        {"rotation", serializable_array_2d},
        {"fy", fov2focal(cam._fov_y, cam._height)},
        {"fx", fov2focal(cam._fov_x, cam._width)}};

    return camera_entry;
}