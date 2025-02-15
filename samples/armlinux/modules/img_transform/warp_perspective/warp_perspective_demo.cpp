#include <assert.h>

#include <iostream>

#include "flycv.h"
#include "gflags/gflags.h"
#include "utils/test_util.h"

using namespace g_fcv_ns;

DEFINE_string(input_file, "../../bin/" + BGR_1280X720_U8_BIN, "input image bin file path, generate Mat");
DEFINE_int32(input_width, IMG_720P_WIDTH, "input image width");
DEFINE_int32(input_height, IMG_720P_HEIGHT, "input image height");
DEFINE_string(output_file, "", "output image file path");

int main(int argc, char *argv[]) {
    gflags::ParseCommandLineFlags(&argc, &argv, true);
    assert(!FLAGS_input_file.empty());

    Mat img_src(FLAGS_input_width, FLAGS_input_height, FCVImageType::PKG_BGR_U8);
    int status = read_binary_file(FLAGS_input_file, img_src.data(), img_src.total_byte_size());
    if (status != 0) {
        std::cout << "Failed to read file: " << FLAGS_input_file << std::endl;
        return -1;
    }

    Mat img_dst;

    Point2f src_pts[4] = {Point2f(165, 270), Point2f(360, 125), Point2f(615, 125), Point2f(835, 270)};
    Point2f dst_pts[4] = {Point2f(160, 260), Point2f(360, 125), Point2f(615, 125), Point2f(835, 270)};

    Mat trans_m = get_perspective_transform(src_pts, dst_pts);

    status = warp_perspective(img_src, img_dst, trans_m);
    if (status != 0) {
        std::cout << "Failed to transform" << std::endl;
        return -1;
    }

    if (!FLAGS_output_file.empty()) {
        imwrite(FLAGS_output_file, img_dst);
    }

    return 0;
}
